package Events
{
   public class ActionDropEvent extends DynamicObjectEvent
   {
      
      public function ActionDropEvent(type:String, data:Object = null, bubbles:Boolean = false, cancelable:Boolean = false)
      {
         super(type,data,bubbles,cancelable);
      }
   }
}

