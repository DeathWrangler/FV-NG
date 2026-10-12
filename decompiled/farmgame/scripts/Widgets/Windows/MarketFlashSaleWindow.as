package Widgets.Windows
{
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Managers.MarketFlashSaleManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.TextFields.FarmTextField;
   import flash.events.MouseEvent;
   
   public class MarketFlashSaleWindow extends FarmWindow
   {
      
      protected static const DIALOG_ASSET:String = "assets/dialogs/MarketplaceFlashSale2012_motd.swf";
      
      public function MarketFlashSaleWindow()
      {
         super(DIALOG_ASSET);
         Global.player.setSeenSessionFlag(MarketFlashSaleManager.MARKET_FLASH_SALE_SEEN_FLAG,true);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(m_window)
         {
            addWidget(new ZwBaseWidget(m_window.mainWindow));
            addWidget(new FarmAnimatedTextButton(m_window.mainWindow.accept_bt,ZLocUtils.t("Dialogs","CheckItOut"),this.onAccept));
            addWidget(new FarmTextField(m_window.mainWindow.headline_tf,ZLocUtils.t("Dialogs","MarketSaleMOTD_headline",{
               "off":MarketFlashSaleManager.instance.getSaleOffPercentage(),
               "minFC":MarketFlashSaleManager.instance.getSaleMinAffectedItemCost() - 1
            })));
            addWidget(new FarmTextField(m_window.mainWindow.body_tf,ZLocUtils.t("Dialogs","MarketSaleMOTD_body")));
         }
      }
      
      protected function onAccept(event:MouseEvent) : void
      {
         UI.displayMarketDialog("MarketFlashSale","limited");
         this.close();
      }
   }
}

