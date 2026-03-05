import 'package:flutter/material.dart';

class ModernAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final bool hasSearch;
  final Function(String)? onSearchChanged;
  final TextEditingController? searchController;
  final List<Widget>? actions;
  final String? searchHint;
  final VoidCallback? onSearchClear;

  const ModernAppBar({
    super.key,
    required this.title,
    this.hasSearch = false,
    this.onSearchChanged,
    this.searchController,
    this.actions,
    this.searchHint,
    this.onSearchClear,
  });

  @override
  State<ModernAppBar> createState() => _ModernAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _ModernAppBarState extends State<ModernAppBar>
    with SingleTickerProviderStateMixin {
  bool _isSearchActive = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearchActive = !_isSearchActive;
      if (_isSearchActive) {
        _animationController.forward();
      } else {
        _animationController.reverse();
        widget.searchController?.clear();
        widget.onSearchClear?.call();
        FocusScope.of(context).unfocus();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          if (!widget.hasSearch || !_isSearchActive) {
            return Text(widget.title);
          }
          
          return Transform.scale(
            scale: _animation.value,
            alignment: Alignment.centerLeft,
            child: FadeTransition(
              opacity: _animation,
              child: TextField(
                controller: widget.searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: widget.searchHint ?? "Search...",
                  border: InputBorder.none,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear, color: Colors.white),
                    onPressed: () {
                      widget.searchController?.clear();
                      widget.onSearchChanged?.call('');
                    },
                  ),
                ),
                onChanged: widget.onSearchChanged,
              ),
            ),
          );
        },
      ),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
            ],
          ),
        ),
      ),
      actions: [
        if (widget.hasSearch)
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return IconButton(
                icon: Icon(
                  _isSearchActive ? Icons.close : Icons.search,
                  color: Colors.white,
                ),
                onPressed: _toggleSearch,
              );
            },
          ),
        ...?widget.actions,
      ],
    );
  }
}

class GradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final Color? backgroundColor;

  const GradientAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = false,
    this.backgroundColor,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      centerTitle: centerTitle,
      leading: leading,
      actions: actions,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: backgroundColor != null
                ? [backgroundColor!, backgroundColor!]
                : [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary,
                  ],
          ),
        ),
      ),
    );
  }
}
