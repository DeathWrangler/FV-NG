package Display.Dialogs
{
   import flash.utils.Dictionary;
   
   public class GenericDialogConfig
   {
      
      public static const COLOR_GREEN:String = "green";
      
      public static const COLOR_RED:String = "red";
      
      public static const COLOR_BLUE:String = "blue";
      
      public static const COLOR_TEAL:String = "teal";
      
      public static const BUTTON_TEXT_KEY:String = "text";
      
      public static const BUTTON_COLOR_KEY:String = "color";
      
      public static const BUTTON_CALLBACK_KEY:String = "callback";
      
      private var m_titleText:String;
      
      private var m_bodyText:String;
      
      private var m_imageUrl:String;
      
      private var m_hasCloseButton:Boolean = true;
      
      private var m_buttonData:Vector.<Dictionary>;
      
      private var m_centerText:Boolean = false;
      
      private var m_name:String = null;
      
      public function GenericDialogConfig()
      {
         super();
      }
      
      public function setTitleText(text:String) : void
      {
         this.m_titleText = text;
      }
      
      public function getTitleText() : String
      {
         return this.m_titleText;
      }
      
      public function setBodyText(text:String) : void
      {
         this.m_bodyText = text;
      }
      
      public function getBodyText() : String
      {
         return this.m_bodyText;
      }
      
      public function setName(name:String) : void
      {
         this.m_name = name;
      }
      
      public function getName() : String
      {
         return this.m_name;
      }
      
      public function setImageUrl(url:String) : void
      {
         this.m_imageUrl = url;
      }
      
      public function getImageUrl() : String
      {
         return this.m_imageUrl;
      }
      
      public function showCloseButton(value:Boolean) : void
      {
         this.m_hasCloseButton = value;
      }
      
      public function hasCloseButton() : Boolean
      {
         return this.m_hasCloseButton;
      }
      
      public function addButton(text:String, colorName:String = "green", callback:Function = null) : void
      {
         var buttonData:Dictionary = new Dictionary();
         buttonData[BUTTON_TEXT_KEY] = text;
         buttonData[BUTTON_COLOR_KEY] = colorName;
         buttonData[BUTTON_CALLBACK_KEY] = callback;
         if(this.m_buttonData == null)
         {
            this.m_buttonData = new Vector.<Dictionary>();
         }
         this.m_buttonData.push(buttonData);
      }
      
      private function getButtonData(index:int, dataKey:String) : *
      {
         var buttonData:Dictionary = null;
         var result:* = null;
         if(Boolean(this.m_buttonData) && index < this.m_buttonData.length)
         {
            buttonData = this.m_buttonData[index];
            if(Boolean(buttonData) && buttonData.hasOwnProperty(dataKey))
            {
               result = buttonData[dataKey];
            }
         }
         return result;
      }
      
      public function getButtonText(buttonIndex:int) : String
      {
         return this.getButtonData(buttonIndex,BUTTON_TEXT_KEY);
      }
      
      public function getButtonColor(buttonIndex:int) : String
      {
         return this.getButtonData(buttonIndex,BUTTON_COLOR_KEY);
      }
      
      public function getButtonCallback(buttonIndex:int) : Function
      {
         return this.getButtonData(buttonIndex,BUTTON_CALLBACK_KEY);
      }
      
      public function buttonCount() : int
      {
         var result:int = 0;
         if(this.m_buttonData)
         {
            result = int(this.m_buttonData.length);
         }
         return result;
      }
      
      public function setCenteredText(value:Boolean) : void
      {
         this.m_centerText = value;
      }
      
      public function hasCenteredText() : Boolean
      {
         return this.m_centerText;
      }
   }
}

