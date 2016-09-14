//Created by Action Script Viewer - http://www.buraks.com/asv
package deltax.common {

    public class StringDataParser {

        private var m_textData:String;
        private var m_parseIndex:int;
        private var m_reachedEOF:Boolean;
        private var m_line:int;
        private var m_charLineIndex:int;

        public function StringDataParser(_arg1:String=""){
            this.m_textData = _arg1;
        }
        public function get reachedEOF():Boolean{
            return (this.m_reachedEOF);
        }
        public function set textData(_arg1:String):void{
            this.m_textData = _arg1;
            this.reset();
        }
        public function reset():void{
            this.m_charLineIndex = (this.m_line = (this.m_parseIndex = 0));
            this.m_reachedEOF = false;
        }
        public function getLine():String{
            var _local1:String;
            var _local2 = "";
            while (!(this.m_reachedEOF)) {
                _local1 = this.getNextChar();
                if ((((_local1 == "\r")) || ((_local1 == "\n")))){
                    this.skipWhiteSpace();
                    if (_local2 != ""){
                        return (_local2);
                    };
                } else {
                    _local2 = (_local2 + _local1);
                };
            };
            return (_local2);
        }
        public function getNextToken():String{
            var _local1:String;
            var _local2 = "";
            while (!(this.m_reachedEOF)) {
                _local1 = this.getNextChar();
                if ((((((((_local1 == " ")) || ((_local1 == "\r")))) || ((_local1 == "\n")))) || ((_local1 == "\t")))){
                    this.skipWhiteSpace();
                    if (_local2 != ""){
                        return (_local2);
                    };
                } else {
                    _local2 = (_local2 + _local1);
                };
            };
            return (_local2);
        }
        public function skipWhiteSpace():void{
            var _local1:String;
            do  {
                _local1 = this.getNextChar();
            } while ((((((((_local1 == "\n")) || ((_local1 == " ")))) || ((_local1 == "\r")))) || ((_local1 == "\t"))));
            this.putBack();
        }
        public function ignoreLine():void{
            var _local1:String;
            while (((!(this.m_reachedEOF)) && (!((_local1 == "\n"))))) {
                _local1 = this.getNextChar();
            };
        }
        public function getNextChar():String{
            var _local1:String = this.m_textData.charAt(this.m_parseIndex++);
            if (_local1 == "\n"){
                this.m_line++;
                this.m_charLineIndex = 0;
            } else {
                if (_local1 != "\r"){
                    this.m_charLineIndex++;
                };
            };
            if (this.m_parseIndex >= this.m_textData.length){
                this.m_reachedEOF = true;
            };
            return (_local1);
        }
        public function getNextInt():int{
            var _local1:Number = parseInt(this.getNextToken());
            if (isNaN(_local1)){
                this.sendParseError("int type");
            };
            return (_local1);
        }
        public function getNextNumber():Number{
            var _local1:Number = parseFloat(this.getNextToken());
            if (isNaN(_local1)){
                this.sendParseError("float type");
            };
            return (_local1);
        }
        public function putBack():void{
            this.m_parseIndex--;
            this.m_charLineIndex--;
            this.m_reachedEOF = (this.m_parseIndex >= this.m_textData.length);
        }
        public function parseLiteralString():String{
            this.skipWhiteSpace();
            var _local1:String = this.getNextChar();
            var _local2 = "";
            if (_local1 != "\""){
                this.sendParseError("\"");
            };
            do  {
                if (this.m_reachedEOF){
                    this.sendEOFError();
                };
                _local1 = this.getNextChar();
                if (_local1 != "\""){
                    _local2 = (_local2 + _local1);
                };
            } while (_local1 != "\"");
            return (_local2);
        }
        private function sendEOFError():void{
            throw (new Error("Unexpected end of file"));
        }
        private function sendParseError(_arg1:String):void{
            throw (new Error((((((((("Unexpected token at line " + (this.m_line + 1)) + ", character ") + this.m_charLineIndex) + ". ") + _arg1) + " expected, but ") + this.m_textData.charAt((this.m_parseIndex - 1))) + " encountered")));
        }
        private function sendUnknownKeywordError():void{
            throw (new Error((((("Unknown keyword at line " + (this.m_line + 1)) + ", character ") + this.m_charLineIndex) + ". ")));
        }

    }
}//package deltax.common 
