package GameMode
{
   import Engine.Constants;
   import flash.events.MouseEvent;
   
   public class GMNPCVisit extends GMVisit
   {
      
      public function GMNPCVisit(hostId:String)
      {
         super(hostId);
      }
      
      override protected function getSelectableTypes() : int
      {
         return Constants.WORLDOBJECT_NONE;
      }
      
      override protected function canBeClicked(event:MouseEvent) : Boolean
      {
         return false;
      }
   }
}

