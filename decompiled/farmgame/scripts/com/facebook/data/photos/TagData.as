package com.facebook.data.photos
{
   [Bindable]
   public class TagData
   {
      
      protected var _actualText:String;
      
      protected var _actualX:Number;
      
      protected var _actualY:Number;
      
      public var pid:String;
      
      public var created:Date;
      
      public var tag_uid:String;
      
      public var subject:String;
      
      public function TagData()
      {
         super();
      }
      
      public function set y(param1:Number) : void
      {
         this._actualY = param1;
      }
      
      public function set text(param1:String) : void
      {
         this._actualText = param1;
      }
      
      public function get ycoord() : Number
      {
         return this._actualY;
      }
      
      public function set tag_text(param1:String) : void
      {
         this._actualText = param1;
      }
      
      public function get text() : String
      {
         return this._actualText;
      }
      
      public function set x(param1:Number) : void
      {
         this._actualX = param1;
      }
      
      public function get tag_text() : String
      {
         return this._actualText;
      }
      
      public function set ycoord(param1:Number) : void
      {
         this._actualY = param1;
      }
      
      public function get y() : Number
      {
         return this._actualY;
      }
      
      public function set xcoord(param1:Number) : void
      {
         this._actualX = param1;
      }
      
      public function get xcoord() : Number
      {
         return this._actualX;
      }
      
      public function get x() : Number
      {
         return this._actualX;
      }
   }
}

