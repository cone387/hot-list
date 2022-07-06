import 'package:flutter/material.dart';

class AppBarSearch extends StatefulWidget implements PreferredSizeWidget {
  const AppBarSearch({
    Key? key,
    this.toSearchPage = true,
    this.autoFocus = false,
    this.focusNode,
    this.controller,
    this.value,
    this.leading,
    this.suffix,
    this.actions = const [],
    this.hintText,
    this.onTap,
    this.onClear,
    this.onCancel,
    this.onChanged,
    this.onSearch,
  }) : super(key: key);
  final bool autoFocus;
  final FocusNode? focusNode;
  final TextEditingController? controller;

  final bool toSearchPage;

  // 默认值
  final String? value;

  // 最前面的组件
  final Widget? leading;

  // 搜索框后缀组件
  final Widget? suffix;
  final List<Widget> actions;

  // 提示文字
  final String? hintText;

  // 输入框点击
  final VoidCallback? onTap;

  // 单独清除输入框内容
  final VoidCallback? onClear;

  // 清除输入框内容并取消输入
  final VoidCallback? onCancel;

  // 输入框内容改变
  final ValueChanged? onChanged;

  // 点击键盘搜索
  final ValueChanged? onSearch;

  @override
  _AppBarSearchState createState() => _AppBarSearchState();

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class _AppBarSearchState extends State<AppBarSearch> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    _controller = widget.controller ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();
    if (widget.value != null) _controller.text = widget.value!;
    super.initState();
  }

  // 清除输入框内容
  void _onClearInput() {
    setState(() {
      _controller.clear();
    });
    if (widget.onClear != null) widget.onClear!();
  }

  // 取消输入框编辑
  void _onCancelInput() {
    setState(() {
      _controller.clear();
      _focusNode.unfocus();
    });
    if (widget.onCancel != null) widget.onCancel!();
  }

  void _onInputChanged(String value) {
    setState(() {});
    if (widget.onChanged != null) widget.onChanged!(value);
  }

  Widget _suffix() {
    if (_controller.text.isNotEmpty) {
      return GestureDetector(
        onTap: _onClearInput,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(
            Icons.cancel,
            size: 25,
            color: Color(0xFF999999),
          ),
        ),
      );
    }
    return widget.suffix ??
        SizedBox(
          width: 0,
        );
  }

  List<Widget> _actions() {
    List<Widget> list = [];
    if (_controller.text.isNotEmpty) {
      list.add(GestureDetector(
        onTap: _onCancelInput,
        child: Container(
          width: 48,
          alignment: Alignment.center,
          child: Text(
            '取消',
            style: TextStyle(color: Color(0xFF666666), fontSize: 15),
          ),
        ),
      ));
    } else if (widget.actions.isNotEmpty) {
      list.addAll(widget.actions);
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final ScaffoldState scaffold = Scaffold.of(context);
    // final ModalRoute<dynamic> parentRoute = ModalRoute.of(context);
    // final bool canPop = parentRoute.canPop ?? false;
    // final bool hasDrawer = scaffold?.hasDrawer ?? false;
    bool canPop = false;
    bool hasDrawer = false;
    double left = 0;
    double right = 0;
    if (!canPop && !hasDrawer && widget.leading == null) left = 15;
    if (_controller.text.isEmpty && widget.actions.isEmpty) right = 15;
    return AppBar(
      elevation: 0,
      titleSpacing: 0,
      // 藏返回按钮
      automaticallyImplyLeading: false,
      leading: widget.leading,
      backgroundColor: Color.fromRGBO(250, 250, 250, 0),
      title: Container(
        margin: EdgeInsets.only(right: right, left: left),
        decoration: BoxDecoration(
          color: Color(0xFFF2F2F2),
          borderRadius: BorderRadius.circular(20),
        ),
        // constraints: BoxConstraints(
        //     maxHeight: 25,
        //     maxWidth: 200
        // ),
        child: Row(
          children: [
            SizedBox(
              // width: 40,
              // height: 40,
              child: Padding(
                  child: Icon(
                    Icons.search,
                    size: 24,
                    color: Color(0xFF999999),
                  ),
                  padding: EdgeInsets.only(left: 15)),
            ),
            Expanded(
              child: TextField(
                autofocus: widget.autoFocus,
                focusNode: _focusNode,
                controller: _controller,
                decoration: InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    hintText: widget.hintText ?? '请输入关键字',
                    hintStyle: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF999999),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 8, horizontal: 5)),
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.red, //Color(0xFF333333),
                  height: 1.3,
                ),
                textInputAction: TextInputAction.search,
                onTap: widget.onTap,
                onChanged: _onInputChanged,
                onSubmitted: widget.onSearch,
              ),
            ),
            _suffix(),
          ],
        ),
      ),

      actions: _actions(),
    );
  }
}