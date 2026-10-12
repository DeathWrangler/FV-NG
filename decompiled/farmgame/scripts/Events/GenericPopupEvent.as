package Events
{
   import flash.events.Event;
   
   public class GenericPopupEvent extends Event
   {
      
      public static const SELECTED:String = "selected";
      
      public var rewardLink:String = "";
      
      public var button:int = 0;
      
      public function GenericPopupEvent(type:String, inButton:int, reward:String = "")
      {
         super(type);
         this.button = inButton;
         this.rewardLink = reward;
      }
   }
}

