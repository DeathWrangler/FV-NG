package Transactions
{
   import Classes.Idle.LonelyAnimalIdleTask;
   import Display.GiftMission;
   
   public class TCreateLonelyCow extends TFarmTransaction
   {
      
      protected var m_lonelyCowId:String = "";
      
      public var animalType:String = "";
      
      public function TCreateLonelyCow()
      {
         super();
      }
      
      override public function perform() : void
      {
         signedCall("LonelyCowService.createLonelyAnimal");
      }
      
      override protected function onComplete(result:Object) : void
      {
         this.m_lonelyCowId = result[0] as String;
         if(this.m_lonelyCowId != null && this.m_lonelyCowId.length > 0 && result[1] != null && result[1] != "")
         {
            LonelyAnimalIdleTask.shouldShow = false;
            this.animalType = result[1];
            Global.popupManager.addInactiveUserPopup(new GiftMission(GiftMission.STATUS_HELP_COW,this.animalType,this.m_lonelyCowId),"lonelyCowPopup",true);
            GlobalEngine.log("LonelyCow","Lonely cow created!  Id is: " + this.m_lonelyCowId);
         }
      }
      
      override protected function onFault(errorType:int, errorData:String) : void
      {
         GlobalEngine.log("LonelyCow","Fault in TCreateLonelyCow: " + errorData);
      }
   }
}

