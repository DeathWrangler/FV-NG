package Events
{
   public class SuperBuildingCompleteEvent extends DynamicObjectEvent
   {
      
      public static const EH_COMPLETE:String = "EH_COMPLETE";
      
      public static const BB_COMPLETE:String = "BB_COMPLETE";
      
      public static const HB_COMPLETE:String = "HB_COMPLETE";
      
      public static const BUILDING_COMPLETED:String = "building_completed";
      
      public function SuperBuildingCompleteEvent(type:String, data:Object = null, bubbles:Boolean = false, cancelable:Boolean = false)
      {
         super(type,data,bubbles,cancelable);
      }
   }
}

