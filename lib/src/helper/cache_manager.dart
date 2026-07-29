import 'package:get_storage/get_storage.dart';

final box = GetStorage();

//Always retuns String "" if value is null
dynamic read(String storageName){
  dynamic result = box.read(storageName)??"";
  return result;
}

void write(String storageName,dynamic value){
  box.write(storageName,value??"");
}

void remove(String storageName){
  box.remove(storageName);
}

void clearAllData(){
  // Clear Box
  box.erase();
}

