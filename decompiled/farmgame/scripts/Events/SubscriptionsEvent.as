package Events
{
   public class SubscriptionsEvent extends DynamicObjectEvent
   {
      
      public function SubscriptionsEvent(type:String, data:Object = null, bubbles:Boolean = false, cancelable:Boolean = false)
      {
         super(type,data,bubbles,cancelable);
      }
   }
}

