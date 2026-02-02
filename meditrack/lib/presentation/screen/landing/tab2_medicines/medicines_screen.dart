import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditrack/presentation/screen/base/base_consumer_state.dart';
import 'package:meditrack/presentation/screen/landing/tab2_medicines/medicines_view_model.dart';

import '../../../providers/vm_provider.dart';

class MedicinesScreen extends ConsumerStatefulWidget {
  const MedicinesScreen({super.key});

  @override
  ConsumerState<MedicinesScreen> createState() => _MedicinesScreenState();
}

class _MedicinesScreenState
    extends BaseConsumerState<MedicinesScreen, MedicinesViewModel> with AutomaticKeepAliveClientMixin{
  @override
  void onModelReady(MedicinesViewModel model) {
    model.fetchMedicineList();
    super.onModelReady(model);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Medicine")),
      body: ListView.builder(
        itemCount: viewModel.medicineList.length,
        itemBuilder: (context, index) {
          var item = viewModel.medicineList[index];
          return ListTile(title: Text(item.name));
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
