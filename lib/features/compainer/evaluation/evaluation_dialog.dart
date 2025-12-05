import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:traveller/features/compainer/evaluation/evaluation_service.dart';

class EvaluationDialog extends StatefulWidget {
  final String tripId;
  final String travelerId;
  final String travelerName;
  final String evaluatorId;
  final String evaluatorName;
  final Function(double rating, String comment) onSubmit;

  const EvaluationDialog({
    super.key,
    required this.tripId,
    required this.travelerId,
    required this.travelerName,
    required this.evaluatorId,
    required this.evaluatorName,
    required this.onSubmit,
  });

  @override
  State<EvaluationDialog> createState() => _EvaluationDialogState();
}

class _EvaluationDialogState extends State<EvaluationDialog> {
  final _commentController = TextEditingController();
  double _rating = 3.0;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange[100],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.star,
                  size: 40,
                  color: Colors.orange[700],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Rate Your Trip',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'How was your experience with ${widget.travelerName}?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _rating = index + 1.0;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(
                        index < _rating ? Icons.star : Icons.star_border,
                        size: 40,
                        color: Colors.amber,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 8),
              Text(
                _getRatingText(_rating),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _getRatingColor(_rating),
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _commentController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Share your experience... (optional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: Colors.orange[600]!, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: _isSubmitting ? null : () => Get.back(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitEvaluation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange[600],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Submit',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitEvaluation() async {
    if (_rating < 1) {
      Get.snackbar(
        'Error',
        'Please select a rating',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange[600],
        colorText: Colors.white,
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Call the onSubmit callback and wait for error string (null if success)
      final String? error =
          await widget.onSubmit(_rating, _commentController.text.trim());

      if (mounted) {
        setState(() => _isSubmitting = false);

        if (error == null) {
          Get.back(); // Close dialog if success
          Get.snackbar(
            'Success',
            'Your evaluation has been submitted!',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green[600],
            colorText: Colors.white,
          );
        } else {
          Get.snackbar(
            'Error',
            error,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red[600],
            colorText: Colors.white,
          );
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isSubmitting = false);
      Get.snackbar(
        'Error',
        'Failed to submit evaluation: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[600],
        colorText: Colors.white,
      );
    }
  }

  String _getRatingText(double rating) {
    if (rating >= 5) return 'Excellent! ⭐⭐⭐⭐⭐';
    if (rating >= 4) return 'Very Good! ⭐⭐⭐⭐';
    if (rating >= 3) return 'Good ⭐⭐⭐';
    if (rating >= 2) return 'Fair ⭐⭐';
    return 'Poor ⭐';
  }

  Color _getRatingColor(double rating) {
    if (rating >= 4.0) return Colors.green[700]!;
    if (rating >= 3.0) return Colors.orange[700]!;
    return Colors.red[700]!;
  }
}

// Helper function to show evaluation dialog only if not evaluated before
Future<void> showEvaluationDialog({
  required String tripId,
  required String travelerId,
  required String travelerName,
  required String evaluatorId,
  required String evaluatorName,
}) async {
  bool alreadyEvaluated = await EvaluationService().hasUserEvaluated(
    tripId: tripId,
    evaluatorId: evaluatorId,
  );

  if (alreadyEvaluated) {
    Get.snackbar(
      'Info',
      'You have already rated this trip',
      snackPosition: SnackPosition.BOTTOM,
    );
    return;
  }

  Get.dialog(
    EvaluationDialog(
      tripId: tripId,
      travelerId: travelerId,
      travelerName: travelerName,
      evaluatorId: evaluatorId,
      evaluatorName: evaluatorName,
      onSubmit: (rating, comment) async {
        return await EvaluationService().createEvaluation(
          tripId: tripId,
          evaluatorId: evaluatorId,
          evaluatorName: evaluatorName,
          evaluatorRole: 'companion',
          targetId: travelerId,
          targetName: travelerName,
          rating: rating,
          comment: comment,
        );
      },
    ),
    barrierDismissible: false,
  );
}
