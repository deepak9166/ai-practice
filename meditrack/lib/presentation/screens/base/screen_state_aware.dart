import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screen_state.dart';

typedef WidgetChildBuilder = Widget Function(BuildContext context);

/// Highly reusable, production-grade state-aware widget
class ScreenStateAware extends ConsumerStatefulWidget {
  final Widget? child;
  final WidgetChildBuilder? builder;

  final Widget? progress;
  final Widget? apiProgress;
  final Widget? error;
  final Widget? empty;
  final Widget? noInternet;

  final bool useErrorInAppBar;
  final bool showApiProgressInPlace;

  final ValueNotifier<ScreenState> state;

  final VoidCallback? onEmptyTap;
  final VoidCallback? onErrorTap;
  final VoidCallback? onAction;
  final VoidCallback? onRefreshTrigger;
  final VoidCallback? onInternetRestored;
  final bool Function()? shouldShowNoInternet;

  const ScreenStateAware({
    super.key,
    this.child,
    this.builder,
    required this.state,
    this.progress,
    this.apiProgress,
    this.error,
    this.empty,
    this.noInternet,
    this.useErrorInAppBar = false,
    this.showApiProgressInPlace = false,
    this.onEmptyTap,
    this.onErrorTap,
    this.onAction,
    this.onRefreshTrigger,
    this.onInternetRestored,
    this.shouldShowNoInternet,
  }) : assert(
          (child != null) != (builder != null),
          'Exactly one of `child` or `builder` must be provided.',
        );

  const ScreenStateAware.builder({
    Key? key,
    required WidgetChildBuilder builder,
    required ValueNotifier<ScreenState> state,
    Widget? progress,
    Widget? apiProgress,
    Widget? error,
    Widget? empty,
    Widget? noInternet,
    bool useErrorInAppBar = false,
    bool showApiProgressInPlace = false,
    VoidCallback? onEmptyTap,
    VoidCallback? onErrorTap,
    VoidCallback? onAction,
    VoidCallback? onRefreshTrigger,
    VoidCallback? onInternetRestored,
    bool Function()? shouldShowNoInternet,
  }) : this(
          key: key,
          builder: builder,
          state: state,
          progress: progress,
          apiProgress: apiProgress,
          error: error,
          empty: empty,
          noInternet: noInternet,
          useErrorInAppBar: useErrorInAppBar,
          showApiProgressInPlace: showApiProgressInPlace,
          onEmptyTap: onEmptyTap,
          onErrorTap: onErrorTap,
          onAction: onAction,
          onRefreshTrigger: onRefreshTrigger,
          onInternetRestored: onInternetRestored,
          shouldShowNoInternet: shouldShowNoInternet,
        );

  const ScreenStateAware.child({
    Key? key,
    required Widget child,
    required ValueNotifier<ScreenState> state,
    Widget? progress,
    Widget? apiProgress,
    Widget? error,
    Widget? empty,
    Widget? noInternet,
    bool useErrorInAppBar = false,
    bool showApiProgressInPlace = false,
    VoidCallback? onEmptyTap,
    VoidCallback? onErrorTap,
    VoidCallback? onAction,
    VoidCallback? onRefreshTrigger,
    VoidCallback? onInternetRestored,
    bool Function()? shouldShowNoInternet,
  }) : this(
          key: key,
          child: child,
          state: state,
          progress: progress,
          apiProgress: apiProgress,
          error: error,
          empty: empty,
          noInternet: noInternet,
          useErrorInAppBar: useErrorInAppBar,
          showApiProgressInPlace: showApiProgressInPlace,
          onEmptyTap: onEmptyTap,
          onErrorTap: onErrorTap,
          onAction: onAction,
          onRefreshTrigger: onRefreshTrigger,
          onInternetRestored: onInternetRestored,
          shouldShowNoInternet: shouldShowNoInternet,
        );

  @override
  ConsumerState<ScreenStateAware> createState() => _ScreenStateAwareState();
}

class _ScreenStateAwareState extends ConsumerState<ScreenStateAware>
    with AutomaticKeepAliveClientMixin {
  late ScreenState _previousState;
  Widget? _cachedChild;

  @override
  void initState() {
    super.initState();
    _previousState = widget.state.value;
    widget.state.addListener(_handleStateChange);
    _updateCachedChild(); // Initial cache
  }

  @override
  void didUpdateWidget(covariant ScreenStateAware oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Detect if child changed (parent rebuilt)
    if (oldWidget.child != widget.child) {
      _updateCachedChild(); // Refresh cache when parent rebuilds
    }

    if (oldWidget.state != widget.state) {
      oldWidget.state.removeListener(_handleStateChange);
      widget.state.addListener(_handleStateChange);
      _previousState = widget.state.value;
    }
  }

  void _updateCachedChild() {
    if (widget.child != null) {
      _cachedChild = widget.child;
    }
  }

  @override
  void dispose() {
    widget.state.removeListener(_handleStateChange);
    super.dispose();
  }

  void _handleStateChange() {
    final current = widget.state.value;
    final previous = _previousState;

    if (previous == ScreenState.noInternet &&
        current != ScreenState.noInternet &&
        widget.onInternetRestored != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onInternetRestored!.call();
      });
    }

    if (current == ScreenState.refresh && widget.onRefreshTrigger != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onRefreshTrigger!.call();
      });
    }

    if (current == ScreenState.action && widget.onAction != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onAction!.call();
      });
    }

    _previousState = current;
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Stack(
      children: [
        // Main content layer
        if (widget.builder != null)
          ValueListenableBuilder<ScreenState>(
            valueListenable: widget.state,
            builder: (context, state, _) => Builder(builder: widget.builder!),
          )
        else
          _cachedChild!,

        // Overlay layer
        ValueListenableBuilder<ScreenState>(
          valueListenable: widget.state,
          builder: (context, state, _) {
            final bool shouldShowOverlay = ![
              ScreenState.content,
              ScreenState.refresh,
              ScreenState.action,
              if (widget.showApiProgressInPlace) ScreenState.apiProgress,
              if (!(widget.shouldShowNoInternet?.call() ?? true)) ScreenState.noInternet,
            ].contains(state);

            return Offstage(
              offstage: !shouldShowOverlay,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, animation) =>
                    FadeTransition(opacity: animation, child: child),
                child: _buildOverlayForState(state),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget? _buildOverlayForState(ScreenState state) {
    switch (state) {
      case ScreenState.progress:
        return widget.progress ?? const Center(child: CircularProgressIndicator());

      case ScreenState.apiProgress:
        if (widget.showApiProgressInPlace) return null;
        return Container(
          color: Colors.black.withValues(alpha: 0.05),
          child: widget.apiProgress ??
              const Center(child: CircularProgressIndicator(color: Colors.black)),
        );

      case ScreenState.empty:
        WidgetsBinding.instance.addPostFrameCallback((_) => widget.onEmptyTap?.call());
        return Center(
          key: const ValueKey('empty'),
          child: GestureDetector(
            onTap: widget.onEmptyTap,
            child: widget.empty ?? const Text('No data available'),
          ),
        );

      case ScreenState.error:
        WidgetsBinding.instance.addPostFrameCallback((_) => widget.onErrorTap?.call());
        return Center(
          key: const ValueKey('error'),
          child: widget.error ??
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text('Something went wrong'),
                  if (widget.onErrorTap != null) ...[
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: widget.onErrorTap,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ],
              ),
        );

      case ScreenState.noInternet:
        if (!(widget.shouldShowNoInternet?.call() ?? true)) return null;
        return Center(
          key: const ValueKey('no_internet'),
          child: widget.noInternet ??
              const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.wifi_off, size: 64, color: Colors.orange),
                  SizedBox(height: 16),
                  Text('No internet connection'),
                ],
              ),
        );

      default:
        return null;
    }
  }
}