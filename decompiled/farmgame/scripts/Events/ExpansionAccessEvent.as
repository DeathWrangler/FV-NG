package Events
{
   import flash.events.Event;
   
   public class ExpansionAccessEvent extends Event
   {
      
      public var optionId:String = "";
      
      public function ExpansionAccessEvent(type:String, option:String)
      {
         super(type);
         this.optionId = option;
      }
   }
}

