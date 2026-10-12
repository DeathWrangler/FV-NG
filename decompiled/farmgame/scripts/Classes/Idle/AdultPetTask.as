package Classes.Idle
{
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.GenericPopupTitleBig;
   import Display.UI;
   import Events.GenericPopupTitleBigEvent;
   
   public class AdultPetTask extends BaseIdleTask
   {
      
      private static const POPUP_DELAY:Number = 30000;
      
      protected static var m_shouldShow:Boolean = true;
      
      private var m_petName:String = "";
      
      private var m_isMale:Boolean = false;
      
      public function AdultPetTask(petName:String, isMale:Boolean)
      {
         super();
         this.m_petName = petName;
         this.m_isMale = isMale;
         m_displaysPopup = true;
      }
      
      override public function get requireActionQueueIdle() : Boolean
      {
         return false;
      }
      
      override public function get canFire() : Boolean
      {
         return GlobalEngine.currentTime > POPUP_DELAY;
      }
      
      override public function get shouldAdd() : Boolean
      {
         if(!super.isEligibleForPopups())
         {
            return false;
         }
         return m_shouldShow;
      }
      
      override public function fire() : void
      {
         var message:String = null;
         var dialog:GenericPopupTitleBig = null;
         if(!Global.worldManager.isVisiting())
         {
            if(this.m_isMale)
            {
               message = ZLocUtils.t("Dialogs","PetReachedAdultMessageMale",{"male_name":this.m_petName});
            }
            else
            {
               message = ZLocUtils.t("Dialogs","PetReachedAdultMessageFemale",{"female_name":this.m_petName});
            }
            dialog = new GenericPopupTitleBig("PetReachedAdultTitle",message,GenericPopup.TYPE_ACCEPTCANCEL,this.onBuyTreats);
            dialog.setAcceptTextName("BuyTreats");
            UI.displayPopup(dialog);
         }
         m_shouldShow = false;
      }
      
      private function onBuyTreats(event:GenericPopupTitleBigEvent) : void
      {
         if(event.button == GenericPopup.ACCEPT)
         {
            UI.displayMarketDialog("petsReachAdultBuyTreat","animal",null,"pets");
         }
      }
   }
}

