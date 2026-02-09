import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditrack/core/constants/app_constants.dart';
import 'package:meditrack/core/router/app_router.dart';
import 'package:meditrack/presentation/screen/base/base_consumer_state.dart';
import 'package:meditrack/presentation/screen/landing/tab2_medicines/medicines_view_model.dart';

import '../../../providers/vm_provider.dart';

class MedicinesListScreen extends ConsumerStatefulWidget {
  const MedicinesListScreen({super.key});

  @override
  ConsumerState<MedicinesListScreen> createState() => _MedicinesScreenState();
}

class _MedicinesScreenState
    extends BaseConsumerState<MedicinesListScreen, MedicinesViewModel>
    with AutomaticKeepAliveClientMixin {
  @override
  void onModelReady(MedicinesViewModel model) {
    super.onModelReady(model);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Medicine")),
      body: StreamBuilder(
        stream: viewModel.getAlMedicine(),
        builder: (context, asyncSnapshot) {
          if (asyncSnapshot.hasError) {
            return Center(
              child: Text(
                asyncSnapshot.error.toString(),
                textAlign: TextAlign.center,
              ),
            );
          }

          var data = asyncSnapshot.data ?? [];
          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              var item = data[index];
              return ListTile(
                onTap: () {
                  AppRouter.push(context, AppConstants.routeMedicineDetail, extra: item.id);
                },
                title: Text(item.name));
            },
          );
        },
      ),
    );
  }

  @override
  MedicinesViewModel createViewModel() {
    return ref.read(medicineVm);
  }

  @override
  String screenName() {
    return "Medicine List";
  }

  @override
  bool get wantKeepAlive => true;
}
