package Display
{
   import Classes.Mastery;
   import Classes.ZItem.FarmItem;
   import Classes.ZItem.SeedItem;
   import Classes.util.ZLocUtils;
   import Engine.Managers.SoundManager;
   import Widgets.Windows.MFSSendFreeGifts;
   import ZLocalization.LocalizationObjectToken;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public class MasterySuperCropPopup extends MasteryPopup
   {
      
      private var m_shareSeeds:GenericButton;
      
      private const ASSET_DIALOG:String = "assets/dialogs/FV_SuperCropMasteryPopUp.swf";
      
      public function MasterySuperCropPopup(mastery:Mastery, link:String, difficulty:int, giveReward:Boolean = true)
      {
         super(mastery,link,difficulty,giveReward,this.ASSET_DIALOG);
      }
      
      override protected function onLoadComplete() : void
      {
         var text:String = null;
         m_window = m_loader.content as MovieClip;
         SoundManager.playSound("masteryLevelUp");
         m_window.masteryPop_mc.congratulations_tf.text = ZLocUtils.t("Dialogs","Yeehaw");
         var masterylevel:int = m_mastery.currentLevel + 1;
         var masteryNameToken:LocalizationObjectToken = ZLocUtils.tk("Items",m_mastery.name + "_friendlyName");
         var starName:String = ZLocUtils.t("Dialogs",m_mastery.currentStar);
         m_window.masteryPop_mc.masteryLevel_tf.text = ZLocUtils.t("Dialogs","MasteryTitle",{"quantity":masterylevel});
         this.m_shareSeeds = new GenericButton(m_window.shareSeeds_bt,this.onShareSeedsClick);
         this.m_shareSeeds.text = ZLocUtils.t("Dialogs","ShareSeedsButton");
         var seedItem:SeedItem = Global.farmGameSettingsManager.getFarmItemByName(m_mastery.name) as SeedItem;
         var seedPackageNameToken:LocalizationObjectToken = ZLocUtils.tk("Items",seedItem.seedpackage + "_friendlyName");
         if(m_mastery.gift != "" && Global.player.masterySignEnabled())
         {
            Global.player.addGift(m_mastery.gift);
            if(ZLocUtils.hasString("Dialogs","MasteryRewardSuperCropGift_" + m_mastery.name))
            {
               text = ZLocUtils.t("Dialogs","MasteryRewardSuperCropGift_" + m_mastery.name,{
                  "item":masteryNameToken,
                  "quantity":m_mastery.xp,
                  "coinQuantity":m_mastery.gold
               });
            }
            else
            {
               text = ZLocUtils.t("Dialogs","MasteryRewardSuperCropGift",{
                  "ordinal":starName,
                  "item":masteryNameToken,
                  "quantity":m_mastery.xp,
                  "coinQuantity":m_mastery.gold
               });
            }
         }
         else
         {
            text = ZLocUtils.t("Dialogs","MasteryRewardSuperCropNoGift",{
               "quantity":m_mastery.xp,
               "coinQuantity":m_mastery.gold,
               "ordinal":starName,
               "item":masteryNameToken
            });
         }
         text = text + "\n\n" + ZLocUtils.t("Dialogs","MasteryRewardSuperCropSeeds",{"item":seedPackageNameToken});
         m_window.masteryPop_mc.playerTitle_tf.htmlText = text;
         setTrackerKey("feed-crop_mastery");
         m_window.close_bt.addEventListener(MouseEvent.CLICK,this.onCloseClick);
         addChild(m_window);
      }
      
      override public function onCloseClick(event:MouseEvent) : void
      {
         m_window.shareSeeds_bt.removeEventListener(MouseEvent.CLICK,this.onShareSeedsClick);
         super.onCloseClick(event);
      }
      
      public function onShareSeedsClick(event:MouseEvent) : void
      {
         var seedPackageItem:FarmItem = null;
         m_window.close_bt.removeEventListener(MouseEvent.CLICK,this.onCloseClick);
         m_window.shareSeeds_bt.removeEventListener(MouseEvent.CLICK,this.onShareSeedsClick);
         var seedItem:SeedItem = Global.farmGameSettingsManager.getFarmItemByName(m_mastery.name) as SeedItem;
         if(Boolean(seedItem) && Boolean(seedItem.seedpackage))
         {
            seedPackageItem = Global.farmGameSettingsManager.getFarmItemByName(seedItem.seedpackage);
            UI.displayPopup(new MFSSendFreeGifts(seedPackageItem,"super_seeds_gift_selection",null));
         }
         close();
      }
   }
}

