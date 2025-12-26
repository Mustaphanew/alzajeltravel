import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:alzajeltravel/controller/search_flight_controller.dart';
import 'package:alzajeltravel/utils/app_consts.dart';

class SwapWidget extends StatelessWidget {
  final int index;
  const SwapWidget({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GetBuilder<SearchFlightController>(
      id: 'form-$index', // يضمن إعادة البناء عند التحديث الجزئي
      builder: (controller) {
        final form = controller.forms[index];

        return Align(
          alignment: AlignmentDirectional.centerStart,
          child: InkWell(
            onTap: () {
              controller.swapCities(index);
            },
            child: Container(
              height: 50,
              width: 50,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: cs.surfaceContainer,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: AppConsts.primaryColor, width: 1),
              ),
              child: Icon(
                Icons.swap_vert,
                size: 32,
              )
                  .animate(target: form.isSwappedIcon ? 1 : 0)
                  .rotate(
                    begin: form.isSwappedIcon ? 0 : 0.5,
                    end:   form.isSwappedIcon ? 0.5 : 0, // 0.5 = 180°
                    duration: 400.ms,
                    curve: Curves.easeInOut,
                  ),
            ),
          ),
        );
      },
    );
  }
}

