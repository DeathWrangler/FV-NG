package Events
{
   import flash.events.Event;
   
   public class GenericPopupTitleBigEvent extends Event
   {
      
      public static const SELECTED:String = "selected";
      
      public var itemName:String = "";
      
      public var isCash:Boolean = false;
      
      public var button:int = 0;
      
      public function GenericPopupTitleBigEvent(type:String, inButton:int, item:String = "", cash:Boolean = false)
      {
         super(type);
         this.button = inButton;
         this.itemName = item;
         this.isCash = cash;
      }
   }
}

