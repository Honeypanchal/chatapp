import 'dart:async';
import 'package:chatapp/services/status_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/Status.dart';
import 'package:intl/intl.dart';

// ═════════════════════════════════════════════════════════════════════════════
// ViewStatusScreen  — fixed auto-dismiss race condition
// ═════════════════════════════════════════════════════════════════════════════

class ViewStatusScreen extends StatefulWidget {
  final List<Status> statuses;
  const ViewStatusScreen({super.key, required this.statuses});

  @override
  State<ViewStatusScreen> createState() => _ViewStatusScreenState();
}

class _ViewStatusScreenState extends State<ViewStatusScreen>
    with SingleTickerProviderStateMixin {

  // ─── State ────────────────────────────────────────────────────────────────
  int    _currentIndex = 0;
  bool   _isTyping     = false;
  bool   _isPaused     = false;
  String _currentUserId = '';

  final StatusService         _statusService   = StatusService();
  final TextEditingController _replyController = TextEditingController();

  Timer?                   _autoAdvanceTimer;
  late AnimationController _progressController;

  // Each status stays visible for 7 seconds
  static const Duration _kStatusDuration = Duration(seconds: 7);

  // ─── Lifecycle ────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _currentUserId = FirebaseAuth.instance.currentUser!.uid;

    // Progress bar animation — does NOT trigger navigation on its own
    _progressController = AnimationController(
      vsync: this,
      duration: _kStatusDuration,
    );

    _statusService.fetchAndPrintStatuses();
    _beginStatus(_currentIndex);
  }

  @override
  void dispose() {
    _autoAdvanceTimer?.cancel();
    _progressController.dispose();
    _replyController.dispose();
    super.dispose();
  }

  // ─── Core: start showing a specific status index ──────────────────────────
  void _beginStatus(int index) {
    if (!mounted) return;

    _autoAdvanceTimer?.cancel();
    _progressController.stop();
    _progressController.reset();

    setState(() {
      _currentIndex = index;
      _isTyping     = false;
    });

    // Mark as viewed after 3 s (fire and forget — does NOT close screen)
    _markViewed(index);

    // Start visual progress bar
    _progressController.forward();

    // Auto-advance to next status after full duration
    _autoAdvanceTimer = Timer(_kStatusDuration, () {
      if (!mounted) return;
      _goToNext();
    });
  }

  // Mark viewed silently — no navigation side-effect
  Future<void> _markViewed(int index) async {
    final status = widget.statuses[index];
    if (!status.viewedBy.contains(_currentUserId)) {
      await Future.delayed(const Duration(seconds: 3));
      if (!mounted) return;
      await _statusService.markStatusAsViewed(status.uid, _currentUserId);
      if (mounted) {
        setState(() {
          widget.statuses[index].viewedBy.add(_currentUserId);
        });
      }
    }
  }

  void _goToNext() {
    if (_currentIndex < widget.statuses.length - 1) {
      _beginStatus(_currentIndex + 1);
    } else {
      // All statuses done — go back
      if (mounted) Navigator.pop(context);
    }
  }

  void _goToPrev() {
    if (_currentIndex > 0) {
      _beginStatus(_currentIndex - 1);
    }
  }

  // ─── Pause / resume (long press or typing) ────────────────────────────────
  void _pause() {
    if (_isPaused) return;
    _isPaused = true;
    _autoAdvanceTimer?.cancel();
    _progressController.stop();
  }

  void _resume() {
    if (!_isPaused || _isTyping) return;
    _isPaused = false;
    // Remaining time = remaining fraction × total duration
    final remaining = _kStatusDuration * (1 - _progressController.value);
    _progressController.forward();
    _autoAdvanceTimer = Timer(remaining, () {
      if (mounted) _goToNext();
    });
  }

  // ─── Send reply ───────────────────────────────────────────────────────────
  void _sendReply() async {
    final text = _replyController.text.trim();
    if (text.isEmpty) return;

    final current = widget.statuses[_currentIndex];
    if (current.userId == _currentUserId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You can't reply to your own status")),
      );
      return;
    }

    try {
      await _statusService.sendStatusReply(current.uid, text);
      _replyController.clear();
      if (mounted) {
        setState(() => _isTyping = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Reply sent!')));
        _resume();
      }
    } catch (e) {
      debugPrint('Reply error: $e');
    }
  }

  // ─── Replies bottom sheet ─────────────────────────────────────────────────
  void _showRepliesBottomSheet() {
    _pause();
    final status = widget.statuses[_currentIndex];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36, height: 4,
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                    color: const Color(0xFFE0E0E0),
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const Text('Replies',
                style: TextStyle(
                    fontSize: 17, fontWeight: FontWeight.w800, fontFamily: 'Poppins')),
            const SizedBox(height: 12),
            if (status.statusReplies.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Text('No replies yet',
                      style: TextStyle(color: Color(0xFF888888), fontFamily: 'Poppins')),
                ),
              )
            else
              SizedBox(
                height: 200,
                child: ListView.builder(
                  itemCount: status.statusReplies.length,
                  itemBuilder: (_, i) {
                    final r  = status.statusReplies[i];
                    final by = r['replyBy']   as String? ?? 'Unknown';
                    final tx = r['replyText'] as String? ?? '';
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFFE8F5E9),
                        child: Text(by[0].toUpperCase(),
                            style: const TextStyle(
                                color: Color(0xFF2E7D32), fontWeight: FontWeight.w700)),
                      ),
                      title: Text(by,
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: Text(tx),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    ).whenComplete(_resume);
  }

  // ─── Delete ───────────────────────────────────────────────────────────────
  void _confirmDelete() {
    _pause();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        content: const Text('Delete this status?',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontWeight: FontWeight.w700, fontSize: 15, fontFamily: 'Poppins')),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () { Navigator.pop(context); _resume(); },
            child: const Text('Cancel',
                style: TextStyle(color: Color(0xFF888888))),
          ),
          TextButton(
            onPressed: () async {
              await _statusService.deleteStatus(widget.statuses[_currentIndex].uid);
              if (mounted) {
                Navigator.pop(context); // close dialog
                Navigator.pop(context); // close viewer
              }
            },
            child: const Text('Delete',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────
  Color _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) return Color(int.parse('0xFF$hex'));
    return const Color(0xFF388E3C);
  }

  TextStyle _getTextStyle(String styleIndex) {
    final i = int.tryParse(styleIndex) ?? 0;
    return _textStyles[i % _textStyles.length];
  }

  final List<TextStyle> _textStyles = [
    const TextStyle(fontSize: 24, fontWeight: FontWeight.w800,
        color: Colors.white, fontFamily: 'Poppins', height: 1.4),
    const TextStyle(fontSize: 24, fontStyle: FontStyle.italic,
        color: Colors.white, fontFamily: 'Raleway', height: 1.4),
  ];

  // ─── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final Status status = widget.statuses[_currentIndex];
    final bool isOwner  = status.userId == _currentUserId;

    return GestureDetector(
      onLongPressStart: (_) => _pause(),
      onLongPressEnd:   (_) => _resume(),
      // Tap left third → previous, right two-thirds → next
      onTapUp: (d) {
        final x = d.localPosition.dx;
        final w = MediaQuery.sizeOf(context).width;
        if (x < w * 0.3) { _goToPrev(); } else { _goToNext(); }
      },
      child: Scaffold(
        backgroundColor: _hexToColor(status.backgroundColor),
        body: SafeArea(
          child: Column(
            children: [
              // ── Progress bars ──────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                child: Row(
                  children: List.generate(widget.statuses.length, (i) {
                    return Expanded(
                      child: Container(
                        height: 3,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(2)),
                        child: i < _currentIndex
                        // completed
                            ? Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(2)))
                            : i == _currentIndex
                        // active
                            ? AnimatedBuilder(
                          animation: _progressController,
                          builder: (_, __) => FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: _progressController.value,
                            child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(2))),
                          ),
                        )
                        // future
                            : const SizedBox.shrink(),
                      ),
                    );
                  }),
                ),
              ),

              // ── Header ────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 34, height: 34,
                        decoration: const BoxDecoration(
                            color: Colors.black26, shape: BoxShape.circle),
                        child: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: Colors.white, size: 15),
                      ),
                    ),
                    const SizedBox(width: 10),
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.black26,
                      child: Text(
                        widget.statuses[0].username[0].toUpperCase(),
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w800,
                            fontFamily: 'Poppins'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.statuses[0].username,
                              style: const TextStyle(
                                  color: Colors.white, fontWeight: FontWeight.w700,
                                  fontSize: 14, fontFamily: 'Poppins')),
                          Text(
                            '${DateFormat('HH:mm').format(widget.statuses[0].timestamp.toDate())} · ${_currentIndex + 1} of ${widget.statuses.length}',
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 11, fontFamily: 'Poppins'),
                          ),
                        ],
                      ),
                    ),
                    if (isOwner)
                      GestureDetector(
                        onTap: _confirmDelete,
                        child: Container(
                          width: 34, height: 34,
                          decoration: const BoxDecoration(
                              color: Colors.black26, shape: BoxShape.circle),
                          child: const Icon(Icons.delete_outline_rounded,
                              color: Colors.red, size: 18),
                        ),
                      ),
                  ],
                ),
              ),

              // ── Content ───────────────────────────────────────────────
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(status.text,
                        textAlign: TextAlign.center,
                        style: _getTextStyle(status.textStyle)),
                  ),
                ),
              ),

              // ── Reply bar ─────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: _showRepliesBottomSheet,
                      child: Container(
                        width: 38, height: 38,
                        decoration: const BoxDecoration(
                            color: Colors.black26, shape: BoxShape.circle),
                        child: const Icon(Icons.remove_red_eye_outlined,
                            color: Colors.white, size: 18),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        height: 42,
                        decoration: BoxDecoration(
                            color: Colors.black26,
                            borderRadius: BorderRadius.circular(21)),
                        child: TextField(
                          controller: _replyController,
                          style: const TextStyle(
                              color: Colors.white, fontFamily: 'Poppins'),
                          cursorColor: Colors.white,
                          onChanged: (v) {
                            final typing = v.isNotEmpty;
                            if (typing && !_isTyping) _pause();
                            if (!typing && _isTyping) _resume();
                            setState(() => _isTyping = typing);
                          },
                          decoration: InputDecoration(
                            hintText: 'Reply…',
                            hintStyle: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                                fontFamily: 'Poppins'),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 11),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: _sendReply,
                      child: Container(
                        width: 38, height: 38,
                        decoration: const BoxDecoration(
                            color: Colors.black26, shape: BoxShape.circle),
                        child: const Icon(Icons.send_rounded,
                            color: Colors.white, size: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// ═════════════════════════════════════════════════════════════════════════════
// EnterStatus
// ═════════════════════════════════════════════════════════════════════════════

class EnterStatus extends StatefulWidget {
  const EnterStatus({super.key});

  @override
  State<EnterStatus> createState() => _EnterStatusState();
}

class _EnterStatusState extends State<EnterStatus> {
  final StatusService         _statusService  = StatusService();
  final TextEditingController _statusController = TextEditingController();

  int _selectedStyleIndex = 0;
  int _colorIndex         = 0;

  final List<TextStyle> _textStyles = [
    const TextStyle(fontSize: 24, fontWeight: FontWeight.w800,
        fontFamily: 'Poppins',  color: Colors.white, height: 1.4),
    const TextStyle(fontSize: 24, fontStyle: FontStyle.italic,
        fontFamily: 'Raleway',  color: Colors.white, height: 1.4),
    const TextStyle(fontSize: 24, fontFamily: 'Rubik',
        color: Colors.white, height: 1.4),
    const TextStyle(fontSize: 24, fontWeight: FontWeight.w800,
        fontStyle: FontStyle.italic,
        fontFamily: 'CedarvilleCursive', color: Colors.white, height: 1.4),
  ];

  final List<Color> _backgroundColors = [
    const Color(0xFF388E3C), // green  (default – matches theme)
    const Color(0xFF1976D2), // blue
    const Color(0xFF7B1FA2), // purple
    const Color(0xFFE91E63), // pink
    const Color(0xFFF57C00), // orange
    const Color(0xFF00796B), // teal
  ];

  final List<String> _colorHexCodes = [
    '#2E7D32', '#1565C0', '#6A1B9A', '#C2185B', '#E65100', '#004D40',
  ];

  void _changeColor() =>
      setState(() => _colorIndex = (_colorIndex + 1) % _backgroundColors.length);

  void _changeTextStyle() =>
      setState(() => _selectedStyleIndex = (_selectedStyleIndex + 1) % _textStyles.length);

  void _uploadTextStatus() {
    if (_statusController.text.trim().isEmpty) return;
    _statusService.uploadStatus(
      _statusController.text.trim(),
      _colorHexCodes[_colorIndex],
      _selectedStyleIndex.toString(),
    );
    _statusController.clear();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final width  = MediaQuery.sizeOf(context).width;

    return Scaffold(
      backgroundColor: _backgroundColors[_colorIndex],
      body: SafeArea(
        child: Column(
          children: [
            // ── Top action bar ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
              child: Row(
                children: [
                  // Close
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                          color: Colors.black26, shape: BoxShape.circle),
                      child: const Icon(Icons.close_rounded,
                          color: Colors.white, size: 20),
                    ),
                  ),
                  const Spacer(),
                  // Style picker
                  GestureDetector(
                    onTap: _changeTextStyle,
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                          color: Colors.black26, shape: BoxShape.circle),
                      child: const Icon(Icons.text_fields_rounded,
                          color: Colors.white, size: 20),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Color picker
                  GestureDetector(
                    onTap: _changeColor,
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                          color: Colors.black26, shape: BoxShape.circle),
                      child: const Icon(Icons.color_lens_rounded,
                          color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),

            // ── Style chips ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: List.generate(_textStyles.length, (i) {
                    final bool active = i == _selectedStyleIndex;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedStyleIndex = i),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: active ? Colors.white : Colors.black26,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          ['Bold', 'Italic', 'Normal', 'Cursive'][i],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: active
                                ? _backgroundColors[_colorIndex]
                                : Colors.white,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),

            // ── Text input area ─────────────────────────────────────────
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: TextField(
                    controller: _statusController,
                    textAlign: TextAlign.center,
                    maxLines: 5,
                    style: _textStyles[_selectedStyleIndex],
                    cursorColor: Colors.white,
                    decoration: InputDecoration(
                      hintText: 'Type something…',
                      hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 20,
                          fontFamily: 'Poppins'),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
            ),

            // ── Color swatches row ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: List.generate(_backgroundColors.length, (i) {
                    return GestureDetector(
                      onTap: () => setState(() => _colorIndex = i),
                      child: Container(
                        width: 28,
                        height: 28,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: _backgroundColors[i],
                          shape: BoxShape.circle,
                          border: _colorIndex == i
                              ? Border.all(color: Colors.white, width: 2.5)
                              : null,
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _uploadTextStatus,
        backgroundColor: Colors.black26,
        elevation: 0,
        child: const Icon(Icons.send_rounded, color: Colors.white, size: 24),
      ),
    );
  }
}