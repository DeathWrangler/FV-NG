package Classes
{
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.GenericIconPopup;
   import Display.GenericPopup;
   import Display.UI;
   import Events.GenericPopupEvent;
   import Managers.FarmStatsManager;
   
   public class PregnantSow extends ShareableHarvestAnimal
   {
      
      public function PregnantSow(animalType:String = null)
      {
         super(animalType);
      }
      
      override public function loadObject(data:Object) : void
      {
         super.loadObject(data);
         if(isHarvestable())
         {
            FarmStatsManager.count("piglets_mechanic","recipient_flow","expecting_sow_on_farm");
         }
      }
      
      override public function harvest(energySource:int = 0, energy:Number = 0, showNoEnergyMessage:Boolean = true, updateBackend:Boolean = true, neighborId:String = "0") : Boolean
      {
         var popupMessage:String = null;
         var pregnantSowItem:FarmItem = null;
         var iconUrl:String = null;
         var sharePopup:GenericIconPopup = null;
         var result:Boolean = super.harvest(energySource,energy,showNoEnergyMessage,updateBackend);
         if(result)
         {
            detach();
            Global.world.redrawObjectsOfClass(ShareableHarvestAnimal);
            Global.player.addGift("pig");
            popupMessage = ZLocUtils.t("Dialogs","PregnantSowThanksPopup_message");
            pregnantSowItem = Global.farmGameSettingsManager.getFarmItemByName("pregnantsow");
            iconUrl = pregnantSowItem.icon;
            sharePopup = new GenericIconPopup(popupMessage,GenericPopup.TYPE_SHARECANCEL,this.onSharePopupClose,iconUrl);
            UI.displayPopup(sharePopup);
            FarmStatsManager.count("piglets_mechanic","recipient_flow","user_clicks_expecting_sow");
         }
         return result;
      }
      
      public function onSharePopupClose(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.ACCEPT)
         {
            FarmStatsManager.count("piglets_mechanic","recipient_flow","user_clicks_share_piglets");
            GlobalEngine.socialNetwork.redirect("gifts_send.php?ref=pregnantsow&gift=piglet");
         }
      }
      
      override public function canBeClickedOnVisit() : Boolean
      {
         return false;
      }
   }
}

