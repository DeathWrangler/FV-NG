package Transactions
{
   import Classes.ExtendedPermissionState;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Managers.FarmStatsManager;
   import Managers.ToasterManager;
   import Widgets.Windows.IconToasterWindow;
   
   public class TGrantExtendedPermissions extends TFarmTransaction
   {
      
      private var m_motdSeenType:int = 0;
      
      public function TGrantExtendedPermissions(motdSeenType:int = 0)
      {
         this.m_motdSeenType = motdSeenType;
         super();
      }
      
      override public function perform() : void
      {
         signedCall("SNPermissionsService.grantExtendedPermissionsWithGift");
      }
      
      override protected function onComplete(result:Object) : void
      {
         var giftItem:FarmItem = null;
         var assetPath:String = null;
         var text:String = null;
         if(Boolean(result != null && result.receivedExtendedPermissionsGift) && Boolean(result.receivedExtendedPermissionsGift == "true") && Boolean(result.giftName))
         {
            Global.player.addGift(result.giftName);
            giftItem = Global.farmGameSettingsManager.getFarmItemByName(result.giftName);
            assetPath = giftItem.icon;
            text = ZLocUtils.t("Dialogs","ExtendedPermissionToasterReward");
            ToasterManager.getInstance().togglePause(false);
            ToasterManager.getInstance().add(new IconToasterWindow(assetPath,text));
            if(this.m_motdSeenType == ExtendedPermissionState.EXISTING_PERMISSION_GRANT)
            {
               FarmStatsManager.count("open_graph_permissions_2","incentive_item_granted_old");
            }
            else if(this.m_motdSeenType == ExtendedPermissionState.NEW_PERMISSION_GRANT)
            {
               FarmStatsManager.count("open_graph_permissions_2","incentive_item_granted_new");
            }
         }
      }
   }
}

