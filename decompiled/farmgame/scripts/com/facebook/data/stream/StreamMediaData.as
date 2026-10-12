package com.facebook.data.stream
{
   [Bindable]
   public class StreamMediaData
   {
      
      public var src:String;
      
      public var music:MusicMedia;
      
      public var alt:String;
      
      public var href:String;
      
      public var flash:FlashMedia;
      
      public var photo:PhotoMedia;
      
      public var type:String;
      
      public var video:VideoMedia;
      
      public function StreamMediaData()
      {
         super();
      }
      
      public function toString() : String
      {
         return ["type: " + this.type,"href: " + this.href,"src: " + this.src,"alt: " + this.alt,"photo: " + this.photo,"video: " + this.video,"flash: " + this.flash].join(": ");
      }
   }
}

