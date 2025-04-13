import 'package:flutter/material.dart';
import 'package:uneconly/common/localization/localization.dart';

class HomeWidgetTutorial extends StatelessWidget {
  const HomeWidgetTutorial({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.string.homeWidget),
      ),
      body: Align(
        alignment: Alignment.center,
        child: Image.network(
          const String.fromEnvironment('HOME_WIDGET_TUTORIAL'),
          fit: BoxFit.cover,
          alignment: Alignment.center,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) {
              return child;
            }

            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
        ),
      ),
    );
  }
}
