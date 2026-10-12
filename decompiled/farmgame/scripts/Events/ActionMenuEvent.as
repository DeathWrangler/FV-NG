package Events
{
   import flash.events.MouseEvent;
   
   public class ActionMenuEvent extends MouseEvent
   {
      
      public static const ONPLOW:String = "onPlow";
      
      public static const ONWALK:String = "onWalk";
      
      public function ActionMenuEvent(type:String)
      {
         super(type);
      }
   }
}

