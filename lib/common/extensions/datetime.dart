
// ignore_for_file: non_constant_identifier_names


extension on int{
    String toFixedString(int length){
        String ret = '$this';
        if (ret.length < length) {
            ret = '0' * (length - ret.length) + ret;
        }
        return ret;
    }
}


extension DateTimeExtension on DateTime{

    String get YYmmddHHMMSS{
        return "${this.year}-${this.month.toFixedString(2)}-${this.day.toFixedString(2)} ${this.hour.toFixedString(2)}:${this.minute.toFixedString(2)}:${this.second.toFixedString(2)}";
    }

    String get YYmmdd{
        return "${this.year}-${this.month.toFixedString(2)}-${this.day.toFixedString(2)}"; 
    }

    String get YYmm{
        return "${this.year}-${this.month.toFixedString(2)}"; 
    }

    String get hhmm{
        return "${this.hour.toFixedString(2)}:${this.minute.toFixedString(2)}"; 
    }

    String get smartFormat{
      DateTime now = DateTime.now();
      if(now.difference(this).inDays > 0){
        return YYmmdd;
      }
      return hhmm;
    }
    
}
