import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;

void main() => runApp(const MainApp());

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  bool showSidebar = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.dark,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.purple,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.purple,
          brightness: Brightness.dark,
        ),
      ),
      home: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: Colors.grey[800],
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text("Unscaled Transform Demo"),
                  Spacer(),
                  FilledButton.icon(
                    onPressed: () => setState(() => showSidebar = !showSidebar),
                    icon: Icon(
                      showSidebar ? Icons.visibility_off : Icons.visibility,
                    ),
                    label: Text(showSidebar ? "Hide Sidebar" : "Show Sidebar"),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  if (showSidebar)
                    Container(
                      width: 200,
                      color: Colors.grey[900],
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text("Sidebar"),
                          ),
                          ...List.generate(
                            10,
                            (i) => ListTile(
                              leading: Icon(Icons.folder),
                              title: Text("Item $i"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: 1500,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Hello World"),
                                    FittedBox(
                                      fit: BoxFit.contain,
                                      child: SizedBox(
                                        width: 2000,
                                        height: 2000,
                                        child: Column(
                                          children: [
                                            Text(
                                              "Hello World inside FittedBox",
                                            ),
                                            PopupButton(
                                              sidebarWidth:
                                                  showSidebar ? 200.0 : 0.0,
                                            ),
                                            SizedBox(height: 50),
                                            PopupButton(
                                              sidebarWidth:
                                                  showSidebar ? 200.0 : 0.0,
                                            ),
                                            PopupCoverSelf(),
                                          ],
                                        ),
                                      ),
                                    ),
                                    ...List.generate(
                                      100,
                                      (i) => Text("Line $i"),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              height: 200,
                              color: Colors.grey[900],
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  Icon(Icons.info),
                                  Text("Some content at the bottom"),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PopupCoverSelf extends StatefulWidget {
  const PopupCoverSelf({super.key});

  @override
  State<PopupCoverSelf> createState() => _PopupCoverSelfState();
}

class _PopupCoverSelfState extends State<PopupCoverSelf> {
  final controller = OverlayPortalController();
  final link = UnscaledLink();

  double _getScaleFactor() {
    final leader = link.leader;
    if (leader == null) return 1.0;

    final topLeft = leader.localToGlobal(Offset.zero);
    final bottomRight = leader.localToGlobal(Offset(200, 200));

    final actualWidth = bottomRight.dx - topLeft.dx;
    return actualWidth / 200.0;
  }

  @override
  Widget build(BuildContext context) {
    return UnscaledTarget(
      link: link,
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.red, width: 2),
        ),
        child: Center(
          child: OverlayPortal(
            controller: controller,
            overlayChildBuilder: (_) {
              final scaleFactor = _getScaleFactor();
              final scaledWidth = (link.leaderSize?.width ?? 200) * scaleFactor;
              final scaledHeight =
                  (link.leaderSize?.height ?? 200) * scaleFactor;

              return UnscaledFollower(
                link: link,
                offset: Offset.zero,
                clipToLeaderBounds: true, // Clip to visible portion of trigger
                child: Stack(
                  children: [
                    Positioned(
                      child: Container(
                        width: scaledWidth,
                        height: scaledHeight,
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.8),
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Popup Covering Container',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: controller.hide,
                                child: Text('Close'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
            child: ElevatedButton(
              onPressed: controller.toggle,
              child: Text('Show Popup'),
            ),
          ),
        ),
      ),
    );
  }
}

class PopupButton extends StatefulWidget {
  const PopupButton({super.key, required this.sidebarWidth});
  final double sidebarWidth;

  @override
  State<PopupButton> createState() => _PopupButtonState();
}

class _PopupButtonState extends State<PopupButton> {
  final controller = OverlayPortalController();
  final link = UnscaledLink();

  @override
  Widget build(BuildContext context) {
    return UnscaledTarget(
      link: link,
      child: FilledButton(
        onPressed: controller.toggle,
        child: OverlayPortal(
          controller: controller,
          overlayChildBuilder: (_) => UnscaledFollower(
            link: link,
            offset: Offset(0, 40),
            clipPadding: EdgeInsets.only(
              top: 64,
              left: widget.sidebarWidth,
              bottom: 200,
            ),
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 200,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Non-scaled popup!",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    SizedBox(height: 8),
                    Text("Follows button, not scaled."),
                    SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: controller.hide,
                      child: Text("Close"),
                    ),
                  ],
                ),
              ),
            ),
          ),
          child: Text("Open Popup"),
        ),
      ),
    );
  }
}

// ============================================================================
// UnscaledTarget & UnscaledFollower - Popup follows target without inheriting scale
// ============================================================================

class UnscaledLink {
  RenderBox? leader;
  Size? leaderSize;
}

class UnscaledTarget extends SingleChildRenderObjectWidget {
  const UnscaledTarget({super.key, required this.link, super.child});
  final UnscaledLink link;

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderTarget(link);
  @override
  void updateRenderObject(
    BuildContext context,
    covariant _RenderTarget renderObject,
  ) =>
      renderObject._link = link;
}

class _RenderTarget extends RenderProxyBox {
  _RenderTarget(this._link);
  UnscaledLink _link;

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _link.leader = this;
  }

  @override
  void detach() {
    _link.leader = null;
    super.detach();
  }

  @override
  void performLayout() {
    super.performLayout();
    _link.leaderSize = size;
  }

  /// Get the visible bounds of this render object by intersecting with all ancestor viewports
  Rect? getVisibleBounds() {
    if (!attached) return null;

    final globalPos = localToGlobal(Offset.zero);
    Rect visibleRect = globalPos & size;

    // Walk up the tree and intersect with any clipping/viewport ancestors
    RenderObject? current = parent;
    while (current != null) {
      if (current is RenderBox) {
        // Check for viewport (ScrollView clips content)
        if (current is RenderAbstractViewport) {
          final viewportGlobalPos = current.localToGlobal(Offset.zero);
          final viewportRect = viewportGlobalPos & current.size;
          visibleRect = visibleRect.intersect(viewportRect);
          if (visibleRect.isEmpty) return null;
        }
      }
      current = current.parent;
    }

    return visibleRect.isEmpty ? null : visibleRect;
  }
}

class UnscaledFollower extends SingleChildRenderObjectWidget {
  const UnscaledFollower({
    super.key,
    required this.link,
    this.offset = Offset.zero,
    this.clipPadding,
    this.clipToLeaderBounds = false,
    super.child,
  });
  final UnscaledLink link;
  final Offset offset;
  final EdgeInsets? clipPadding;

  /// If true, clips the popup to the visible bounds of the leader (trigger)
  final bool clipToLeaderBounds;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderFollower(link, offset, clipPadding, clipToLeaderBounds);
  @override
  void updateRenderObject(
    BuildContext context,
    covariant _RenderFollower renderObject,
  ) =>
      renderObject
        .._link = link
        .._offset = offset
        .._clipPadding = clipPadding
        .._clipToLeaderBounds = clipToLeaderBounds
        ..markNeedsPaint();
}

class _RenderFollower extends RenderProxyBox {
  _RenderFollower(
    this._link,
    this._offset,
    this._clipPadding,
    this._clipToLeaderBounds,
  );
  UnscaledLink _link;
  Offset _offset;
  EdgeInsets? _clipPadding;
  bool _clipToLeaderBounds;

  @override
  bool get alwaysNeedsCompositing => true;
  @override
  _FollowerLayer? get layer => super.layer as _FollowerLayer?;

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    final t = layer?._transform;
    return t == null
        ? false
        : result.addWithPaintTransform(
            transform: t,
            position: position,
            hitTest: (r, p) => super.hitTestChildren(r, position: p),
          );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    layer = (layer ?? _FollowerLayer())
      .._link = _link
      .._offset = _offset
      .._follower = this
      .._clipPadding = _clipPadding
      .._clipToLeaderBounds = _clipToLeaderBounds;
    context.pushLayer(
      layer!,
      super.paint,
      Offset.zero,
      childPaintBounds: Rect.largest,
    );
  }

  @override
  void applyPaintTransform(RenderBox child, Matrix4 transform) {
    if (layer?._transform != null) transform.multiply(layer!._transform!);
  }

  @override
  void detach() {
    layer = null;
    super.detach();
  }
}

class _FollowerLayer extends ContainerLayer {
  UnscaledLink? _link;
  Offset _offset = Offset.zero;
  RenderBox? _follower;
  EdgeInsets? _clipPadding;
  bool _clipToLeaderBounds = false;
  Matrix4? _transform;

  @override
  bool get alwaysNeedsAddToScene => true;

  @override
  void addToScene(ui.SceneBuilder builder) {
    final leader = _link?.leader;
    if (leader == null || !leader.attached) {
      engineLayer = null;
      return;
    }

    // Cast to _RenderTarget to access getVisibleBounds
    final renderTarget = leader as _RenderTarget;

    final leaderPos = leader.localToGlobal(Offset.zero);
    final followerPos = (_follower != null && _follower!.attached)
        ? _follower!.localToGlobal(Offset.zero)
        : Offset.zero;
    final dx = leaderPos.dx - followerPos.dx + _offset.dx;
    final dy = leaderPos.dy - followerPos.dy + _offset.dy;

    // Determine clip rect - priority: clipPadding > clipToLeaderBounds
    Rect? clipRect;
    final padding = _clipPadding;
    if (padding != null) {
      final view = ui.PlatformDispatcher.instance.views.first;
      final windowSize = view.physicalSize / view.devicePixelRatio;
      clipRect = Rect.fromLTRB(
        padding.left,
        padding.top,
        windowSize.width - padding.right,
        windowSize.height - padding.bottom,
      );
    } else if (_clipToLeaderBounds) {
      clipRect = renderTarget.getVisibleBounds();
    }

    if (clipRect != null) {
      builder.pushClipRect(clipRect);
    }

    _transform = Matrix4.translationValues(dx, dy, 0);
    engineLayer = builder.pushTransform(
      _transform!.storage,
      oldLayer: engineLayer as ui.TransformEngineLayer?,
    );
    addChildrenToScene(builder);
    builder.pop();
    if (clipRect != null) builder.pop();
  }

  @override
  void applyTransform(Layer? child, Matrix4 transform) {
    if (_transform != null) transform.multiply(_transform!);
  }
}
