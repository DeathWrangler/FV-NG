package Classes
{
   import Classes.util.ZLocUtils;
   import Display.ContextMenuItem;
   import Display.GenericPopup;
   import Display.MysteryBoxBalloonDialog;
   import Display.UI;
   import Events.GenericPopupEvent;
   import Managers.FarmStatsManager;
   import flash.events.MouseEvent;
   
   public class CashGrowableBaby extends GrowableBaby
   {
      
      private const MYSTERY_EXCLUSIVE:String = "mystery_exclusive";
      
      public function CashGrowableBaby(animalType:String = null)
      {
         super(animalType);
      }
      
      override protected function generateMenuItems() : void
      {
         super.generateMenuItems();
         if(!m_adultItem || !m_adultItem.name || isNaN(m_growPrice) || m_growPrice <= 0)
         {
            m_menuItems.unshift({
               "label":ZLocUtils.t("Dialogs","AnimalBreedingGeneric_MysteryExclusiveContextMenu"),
               "action":this.MYSTERY_EXCLUSIVE
            });
         }
      }
      
      override public function onMenuClick(event:MouseEvent) : void
      {
         var item:ContextMenuItem = null;
         var dialog:GenericPopup = null;
         if(event.target is ContextMenuItem)
         {
            item = event.target as ContextMenuItem;
            if(m_wanderingObject != this)
            {
               generateWanderTime();
               switch(item.action)
               {
                  case this.MYSTERY_EXCLUSIVE:
                     FarmStatsManager.count("dialog",m_breedingBuildingType + "_babyexlusive","View");
                     dialog = new GenericPopup(ZLocUtils.t("Dialogs","AnimalBreedingGeneric_MysteryExclusive"),GenericPopup.TYPE_OK,this.onMysteryExclusiveDialogResponse,GenericPopup.GENERIC_ASSET,"",false,false,true);
                     dialog.setAcceptTextName("MysteryGameToaster_Button_Accept");
                     UI.displayPopup(dialog);
                     break;
                  default:
                     super.onMenuClick(event);
               }
            }
         }
      }
      
      override public function paymentName() : String
      {
         return "FC";
      }
      
      protected function onMysteryExclusiveDialogResponse(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.ACCEPT)
         {
            MysteryBoxBalloonDialog.openDefaultMysteryGame();
            FarmStatsManager.count("dialog",m_breedingBuildingType + "_babyexlusive","Mystery Game");
         }
         else
         {
            FarmStatsManager.count("dialog",m_breedingBuildingType + "_babyexlusive","X");
         }
      }
      
      override protected function canTransform() : Boolean
      {
         return Global.player.canBuyCash(m_growPrice,true);
      }
      
      override protected function chargeTransform() : Boolean
      {
         var result:Boolean = false;
         if(Global.player.cash >= m_growPrice)
         {
            Global.player.cash -= m_growPrice;
            result = true;
         }
         return result;
      }
   }
}

