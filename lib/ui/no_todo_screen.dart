import 'package:flutter/material.dart';
import 'package:notodo_app/model/nodo_item.dart';
import 'package:notodo_app/util/database_cliente.dart';
import 'package:notodo_app/util/date_formater.dart' as DtUtil;

class NoTodoScreen extends StatefulWidget {
  _NoTodoScreenState createState() => _NoTodoScreenState();
}

class _NoTodoScreenState extends State<NoTodoScreen> {

  final TextEditingController _textEditingController = new TextEditingController();
  var db = new DatabaseHelper();
  final List<NoDoItem> _itemList = <NoDoItem>[];

  @override
  void initState() {
    super.initState();
    _readNoDoList();
  }

  void _handleSubmit(String item) async {
    _textEditingController.clear();
    NoDoItem noDoItem = new NoDoItem(item, DateTime.now().toIso8601String());
    int itemSavedId = await db.saveItem(noDoItem);

    NoDoItem addedItem = await db.getItem(itemSavedId);

    setState(() {
      _itemList.insert(0, addedItem);      
    });
  }

  void _readNoDoList() async {
    List items = await db.getAll();
    items.forEach((item) {
      // NoDoItem noDoItem = NoDoItem.map(item);
      setState(() {
        _itemList.add(NoDoItem.map(item));
      });
    });
  }

  void _handleSubmitUpdated(int index, NoDoItem item) {
    setState((){
      _itemList.removeWhere((element) {
        _itemList[index].itemName == item.itemName;

      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Colors.black87,
      body: new Column(
        children: <Widget>[
          new Flexible(child: new ListView.builder(
            padding: new EdgeInsets.all(8.0),
            reverse: false,
            itemCount: _itemList.length,
            itemBuilder: (_, int index ) {
              return new Card(
                color: Colors.black87,
                child: new ListTile(
                  title: _itemList[index],
                  onLongPress: () => debugPrint(""), 
                  trailing: new Listener(
                    key: new Key(_itemList[index].itemName),
                    child: new Icon(Icons.remove_circle, color: Colors.redAccent,),
                    onPointerDown: (pointerEvent) {
                      _deleteNoDo(_itemList[index].id, index);
                    },

                  ),
                )
              );
            },
          ),),
          new Divider(height: 1.0,)
        ],
      ),

      floatingActionButton: new FloatingActionButton(
        tooltip: 'Add Item',
        backgroundColor: Colors.redAccent,
        child: new ListTile(
          title: Icon(Icons.add),
        ),
        onPressed: _showFormDialog,
      ),
    );
  }

  void _showFormDialog() {
    var alert = new AlertDialog(
      content: new Row(children: <Widget>[
        new Expanded(
          child: new TextField(
            controller: _textEditingController,
            autofocus: true,
            decoration: new InputDecoration(
              labelText: 'Item',
              hintText: 'eg. dont by stuff',
              icon: new Icon(Icons.note_add)
            ),
          ),
        )
      ],),
      actions: <Widget>[
        new FlatButton(
          onPressed: () {
            _handleSubmit(_textEditingController.text);
            _textEditingController.clear();
            Navigator.pop(context);
          },
          child: Text("Save"),
        ),
        new FlatButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        )
      ],
    );

    showDialog(context: context, builder: (_) {
      return alert;
    });

  }

  _deleteNoDo(int id, int index) async {
    debugPrint("Deleting $id");
    await db.deleteItem(id);
    setState(() {
      _itemList.removeAt(index);
    });
  }

  _updateItem(NoDoItem item, int index) {
    var alert = new AlertDialog(
      title: new Text("Update Item"),
      content: new Row(children: <Widget>[
        new Expanded(
          child: new TextField(
            controller: _textEditingController,
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'Item',
              hintText: 'eg. Dont by stuff',
              icon: new Icon(Icons.update)
            ),
          ),
        )
      ],),
      actions: <Widget>[
        new FlatButton(
          onPressed: () async {
            NoDoItem newItemUpdated = NoDoItem.fromMap({
              "itemName": _textEditingController.text,
              "dateCreated": DtUtil.dateFormated(),
              "id": item.id
            });

            _handleSubmitUpdated(index, item);
            await db.updateItem(newItemUpdated);
            setState(() {
              _readNoDoList();             
            });

            Navigator.pop(context);
          },
          child: new Text("Update"),
        ),
        new FlatButton(
          onPressed: () => Navigator.pop(context),
          child: new Text("Cancel"),
        )
      ],
    );
    showDialog(context: context, builder: (_){
      return alert;
    });
  }
  
}