import 'package:flutter/material.dart';
import 'package:memo_app/edit.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MemoList extends StatefulWidget {
  @override
  MemoListState createState() => MemoListState();
}

class MemoListState extends State<MemoList> {
  var _memoList = new List<String>();
  var _currentIndex = -1;

  bool _loading = true;
  final _biggerFont = const TextStyle(fontSize: 18.0);

  @override
  void initState() {
    super.initState();
    this.loadMemoList();
  }

  // メモを追加
  // edit画面に遷移
  void _addMemo() {
    setState(() {
      _memoList.add("");
      _currentIndex = _memoList.length - 1;
      storeMemoList();
      Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return new Edit(_memoList[_currentIndex], _onChanged);
        },
      ));
    });
  }

  Widget _buildWrappedRow(String content, int index) {
    return Dismissible(
      background: Container(color: Colors.red),
      key: Key(content),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        setState(() {
          _memoList.removeAt(index);
          storeMemoList();
        });
      },
      // スワイプ削除処理
      child: _buildRow(content, index),
    );
  }

  Widget _buildList() {
    final itemCount = _memoList.length == 0 ? 0 : _memoList.length * 2 - 1;
    return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: itemCount,
        itemBuilder: /*1*/ (context, i) {
          if (i.isOdd) return Divider(height: 2);
          final index = (i / 2).floor();
          final memo = _memoList[index];
          return _buildWrappedRow(memo, index);
        });
  }

  @override
  Widget build(BuildContext context) {
    final title = "Home";
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: _buildList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _addMemo,
        tooltip: 'New Memo',
        child: Icon(Icons.add),
      ),
    );
    //    if (_loading) {
//      return Scaffold(
//        appBar: AppBar(
//          title: Text(title),
//        ),
//        body: CircularProgressIndicator(),
//      );
//    }
  }

  void _onChanged(String text) {
    setState(() {
      _memoList[_currentIndex] = text;
      storeMemoList();
    });
  }

  // ローカルに保存
  void storeMemoList() async {
    final prefs = await SharedPreferences.getInstance();
    const key = "memo-list";
    final success = await prefs.setStringList(key, _memoList);
    if (!success) {
      debugPrint("Failed to store value");
    }
  }

  // ローカルに保存したデータ呼び出し
  void loadMemoList() {
    SharedPreferences.getInstance().then((prefs) {
      const key = "memo-list";
      if (prefs.containsKey(key)) {
        _memoList = prefs.getStringList(key);
      }
      setState(() {
        _loading = true;
      });
    });
  }

  // 削除処理
  Widget _buildRow(String content, int index) {
    return ListTile(
      title: Text(
        content,
        style: _biggerFont,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () {
        _currentIndex = index;
        Navigator.of(context)
            .push(MaterialPageRoute<void>(builder: (BuildContext context) {
          return new Edit(_memoList[_currentIndex], _onChanged);
        }));
      },
    );
  }
}
