package Classes.Idle
{
   import Classes.ZItem.SeedItem;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Managers.ToasterManager;
   import Widgets.Windows.IconTitleToasterWindow;
   import flash.events.MouseEvent;
   
   public class MasteredSuperEnabledCropToasterIdleTask extends BaseIdleTask
   {
      
      private var m_baseCrop:SeedItem;
      
      private var m_superCrop:SeedItem;
      
      public function MasteredSuperEnabledCropToasterIdleTask(baseCrop:SeedItem, superCrop:SeedItem)
      {
         this.m_baseCrop = baseCrop;
         this.m_superCrop = superCrop;
         m_displaysPopup = true;
         super();
      }
      
      override public function fire() : void
      {
         var toasterTitle:String = ZLocUtils.t("Dialogs","SuperCrops_Base_Crop_Mastered_Toaster_Title");
         var body:String = ZLocUtils.t("Dialogs","SuperCrops_Base_Crop_Mastered_Toaster_Body",{
            "baseCrop":ZLocUtils.tk_pk(this.m_baseCrop.friendlyName),
            "superCrop":ZLocUtils.tk_pk(this.m_superCrop.friendlyName)
         });
         var superCropsToaster:IconTitleToasterWindow = new IconTitleToasterWindow(toasterTitle,body,this.m_superCrop.icon,"assets/dialogs/FV_Craft_BannerAd.swf",0.75,null,this.onToasterClick);
         ToasterManager.getInstance().add(superCropsToaster);
      }
      
      private function onToasterClick(event:MouseEvent) : void
      {
         UI.displayMiniMarketDialog([this.m_superCrop.name],"market","seed",null);
      }
   }
}

