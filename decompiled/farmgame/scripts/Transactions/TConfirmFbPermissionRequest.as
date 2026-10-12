package Transactions
{
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Managers.FarmStatsManager;
   import Managers.ToasterManager;
   import Widgets.Windows.TwoIconTitleToasterWindow;
   import flash.geom.Point;
   
   public class TConfirmFbPermissionRequest extends TFarmTransaction
   {
      
      private var m_forceFql:Boolean;
      
      public function TConfirmFbPermissionRequest(forceFql:Boolean)
      {
         this.m_forceFql = forceFql;
         super();
      }
      
      override public function perform() : void
      {
         FarmStatsManager.sample(100,"TConfirmFbPermissionRequest","sendingTransaction");
         signedCall("UserService.confirmFbPermissionRequest",this.m_forceFql);
      }
      
      override protected function onComplete(result:Object) : void
      {
         var itemName:String = null;
         var item:FarmItem = null;
         var title:String = null;
         var desc:String = null;
         if(Boolean(result != null) && Boolean(result.isItemGranted) && result.isItemGranted == "true")
         {
            itemName = Global.flashHotParams["FB_PERMISSION_COLLECTION_ITEMNAME"];
            item = Global.farmGameSettingsManager.getFarmItemByName(itemName);
            Global.player.addGift(itemName);
            title = ZLocUtils.t("Dialogs","Toaster_FBPermission_title");
            desc = ZLocUtils.t("Dialogs","Toaster_FBPermission_description",{"itemName":ZLocUtils.tk_pk_asTitle(item.friendlyName)});
            if(Boolean(title) && Boolean(desc) && Boolean(item))
            {
               ToasterManager.getInstance().togglePause(false);
               ToasterManager.getInstance().add(new TwoIconTitleToasterWindow(title,desc,item.icon,"","assets/dialogs/FV_BannerAd_Rewards_generic.swf",1,1,new Point(-33,-25)));
            }
            FarmStatsManager.sample(100,"fv_permission_collection_prompt","item_granted",itemName);
         }
      }
   }
}

