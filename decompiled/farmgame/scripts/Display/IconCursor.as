package Display
{
   import Classes.EmbeddedArt;
   import Engine.Managers.LoadingManager;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.text.TextField;
   
   public class IconCursor extends Sprite
   {
      
      private static const ICON_SIZE:int = 50;
      
      protected var m_element:Object;
      
      protected var m_iconUrl:String;
      
      protected var m_iconLoader:Loader;
      
      protected var m_iconLoadedCallback:Function;
      
      protected var m_icon:DisplayObject;
      
      protected var m_text:String;
      
      protected var m_padding:Number = 2;
      
      public function IconCursor(iconUrl:String, iconLoadedCallback:Function, text:String = "")
      {
         super();
         this.m_element = new EmbeddedArt.cursor_icon();
         addChild(this.m_element as DisplayObject);
         this.m_iconLoadedCallback = iconLoadedCallback;
         this.iconUrl = iconUrl;
         this.text = text;
      }
      
      public function set iconUrl(value:String) : void
      {
         if(this.m_iconUrl != value)
         {
            this.m_iconUrl = value;
            this.m_iconLoader = LoadingManager.load(this.m_iconUrl,this.onIconLoaded,LoadingManager.PRIORITY_HIGH);
         }
      }
      
      public function get iconUrl() : String
      {
         return this.m_iconUrl;
      }
      
      private function onIconLoaded(event:Event) : void
      {
         this.m_icon = this.m_iconLoader.content;
         this.m_icon.width = this.m_icon.height = ICON_SIZE;
         var iconContainer:MovieClip = this.m_element.icon_mc as MovieClip;
         while(iconContainer.numChildren > 0)
         {
            iconContainer.removeChildAt(0);
         }
         iconContainer.addChild(this.m_icon as DisplayObject);
         if(this.m_iconLoadedCallback != null)
         {
            this.m_iconLoadedCallback();
         }
         this.m_iconLoader = null;
      }
      
      public function set text(value:String) : void
      {
         if(this.m_text != value)
         {
            this.m_text = value;
            (this.m_element.count_tf as TextField).text = this.m_text;
         }
      }
      
      public function get text() : String
      {
         return this.m_text;
      }
      
      public function get cursorImage() : Bitmap
      {
         var bitmapData:BitmapData = new BitmapData(width,height,true,0);
         bitmapData.draw(this);
         return new Bitmap(bitmapData);
      }
      
      public function release() : void
      {
         this.m_element = null;
         this.m_icon = null;
         this.m_iconLoader = null;
         this.m_iconLoadedCallback = null;
      }
   }
}

