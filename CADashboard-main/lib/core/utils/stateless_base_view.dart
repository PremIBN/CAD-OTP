
import 'package:cadashboard/core/utils/base_model.dart';
import 'package:flutter/cupertino.dart';
// ignore: depend_on_referenced_packages
import 'package:provider/provider.dart';
/// This will dispose the view model when destroyed.
/// Also You need to create new view model instance and pass it to the view.
class StatelessBaseView<T extends BaseModel> extends StatefulWidget {
  final Widget Function(BuildContext buildContext, T model, Widget? child) builder;
  final Function(T)? onInitState;
  final T model;

  const StatelessBaseView({
    Key? key,
    required this.model,
    this.onInitState,
    required this.builder,
  }) : super(key: key);

  @override
  State<StatelessBaseView<T>> createState() => _BaseViewState<T>();
}

class _BaseViewState<T extends BaseModel> extends State<StatelessBaseView<T>> {
  late T model;

  @override
  void initState() {
    super.initState();
    model = widget.model;
    if (widget.onInitState != null) {
      widget.onInitState!(model);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<T>.value(
      value: model,
      child: Consumer<T>(
        builder: widget.builder,
      ),
    );
  }

  @override
  void dispose() {
    model.dispose();
    super.dispose();
  }
}
