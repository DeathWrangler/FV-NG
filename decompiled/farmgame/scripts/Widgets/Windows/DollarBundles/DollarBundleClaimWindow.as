package Widgets.Windows.DollarBundles
{
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Managers.DollarBundlesManager;
   import Managers.FarmStatsManager;
   import Widgets.Buttons.FarmAnimatedMultiTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import Widgets.Windows.FarmWindow;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class DollarBundleClaimWindow extends FarmWindow
   {
      
      protected var m_title:ZwTextField;
      
      protected var m_icon:FarmIcon;
      
      private const ASSET_PATH:String = "assets/dialogs/FV_DollarBundles_Claim_2015.swf";
      
      private var m_NextBundle_mc:MovieClip = new MovieClip();
      
      private var m_BulbBorder_start_mc:MovieClip = new MovieClip();
      
      private var m_iconTooltip:FarmTextTooltip;
      
      private var m_itemName:String;
      
      private var m_MaxDiscount:Number = 0;
      
      protected var m_item:FarmItem = null;
      
      private var m_BuyButton:FarmAnimatedMultiTextButton;
      
      public function DollarBundleClaimWindow(path:String = null)
      {
         super(this.ASSET_PATH);
         this.m_itemName = DollarBundlesManager.getInstance().getCurrentBundleName();
         this.m_item = Global.farmGameSettingsManager.getFarmItemByName(this.m_itemName);
         this.m_MaxDiscount = DollarBundlesManager.getInstance().getMaxDiscount();
      }
      
      override protected function postLoadComplete() : void
      {
         var iconUrl:String = null;
         var itemBox1:FarmIcon = null;
         var nextBundleName:String = null;
         super.postLoadComplete();
         if(m_window.hasOwnProperty("body_tf"))
         {
            this.m_MaxDiscount = DollarBundlesManager.getInstance().getMaxDiscount();
            addWidget(new ZwTextField(m_window.body_tf,ZLocUtils.t("Dialogs","dollarbundles_claimSubTitle",{
               "maxDiscount":this.m_MaxDiscount.toString(),
               "itemName":this.m_item.friendlyTitle
            })));
         }
         if(m_window.hasOwnProperty("body1_tf"))
         {
            addWidget(new ZwTextField(m_window.body1_tf,ZLocUtils.t("Dialogs","dollarbundles_claimText")));
         }
         if(m_window.hasOwnProperty("bulbBorder_start_mc"))
         {
            this.m_BulbBorder_start_mc = m_window.bulbBorder_start_mc;
            this.m_BulbBorder_start_mc.visible = true;
            this.m_BulbBorder_start_mc.play();
         }
         if(m_window.hasOwnProperty("timer_tf"))
         {
            addWidget(new ZwTextField(m_window.timer_tf,"HURRY!\n" + DollarBundlesManager.getInstance().getTimeRemaining() + "\nLEFT"));
         }
         if(m_window.iconMain_mc != null)
         {
            addWidget(new FarmIcon(m_window.iconMain_mc));
         }
         var itemBox:FarmIcon = getWidget(m_window["iconMain_mc"]) as FarmIcon;
         var currentbundleName:String = DollarBundlesManager.getInstance().getCurrentBundleName();
         this.m_item = Global.farmGameSettingsManager.getFarmItemByName(currentbundleName);
         if(Boolean(itemBox) && Boolean(this.m_item))
         {
            iconUrl = this.m_item.getImageByName(FarmItem.ICON_FEED);
            itemBox.loadIcon(iconUrl);
            itemBox.visible = true;
            this.m_iconTooltip = new FarmTextTooltip(this.m_item.friendlyTitle);
            itemBox.attachTooltip(this.m_iconTooltip);
         }
         var textArray:Array = new Array();
         textArray["priceOriginal_tf"] = "$" + DollarBundlesManager.BUNDLE_ORIGINAL_PRICE.toString();
         var discountPrice:Number = DollarBundlesManager.BUNDLE_ORIGINAL_PRICE - this.m_MaxDiscount * DollarBundlesManager.BUNDLE_ORIGINAL_PRICE / 100;
         textArray["priceDiscounted_tf"] = "$" + discountPrice.toString();
         this.m_BuyButton = new FarmAnimatedMultiTextButton(m_window.buy_bt,textArray,this.buyBundle) as FarmAnimatedMultiTextButton;
         this.m_BuyButton.visible = true;
         var numBundleBought:int = DollarBundlesManager.getInstance().getFeatureOptionsKey(DollarBundlesManager.BOUGHT_BUNDLE_COUNT) as int;
         var bundleArrayLen:int = DollarBundlesManager.getInstance().getBundleArrayLenth();
         if(numBundleBought < bundleArrayLen - 1 && DollarBundlesManager.getInstance().isNextBundleVisible())
         {
            if(m_window.hasOwnProperty("nextBundle_mc"))
            {
               this.m_NextBundle_mc = m_window.nextBundle_mc;
               this.m_NextBundle_mc.visible = true;
               if(this.m_NextBundle_mc)
               {
                  if(this.m_NextBundle_mc.icon_mc != null)
                  {
                     addWidget(new FarmIcon(this.m_NextBundle_mc.icon_mc));
                  }
                  itemBox1 = getWidget(this.m_NextBundle_mc["icon_mc"]) as FarmIcon;
                  nextBundleName = DollarBundlesManager.getInstance().getNextBundleName();
                  if(nextBundleName)
                  {
                     this.m_item = Global.farmGameSettingsManager.getFarmItemByName(nextBundleName);
                     if(Boolean(itemBox1) && Boolean(this.m_item))
                     {
                        itemBox1.loadIcon(this.m_item.icon);
                        itemBox1.visible = true;
                        this.m_iconTooltip = new FarmTextTooltip(this.m_item.friendlyTitle);
                        itemBox1.attachTooltip(this.m_iconTooltip);
                     }
                  }
               }
            }
         }
         FarmStatsManager.count("Superbundle","Action","BundleScreen","view",discountPrice.toString(),"");
      }
      
      public function buyBundle(event:Event) : void
      {
         DollarBundlesManager.getInstance().startBuyTransaction();
         var discountPrice:Number = DollarBundlesManager.BUNDLE_ORIGINAL_PRICE - this.m_MaxDiscount * DollarBundlesManager.BUNDLE_ORIGINAL_PRICE / 100;
         FarmStatsManager.count("Superbundle","Action","Buy_bundle",this.m_itemName,discountPrice.toString(),"");
         this.close();
      }
      
      override public function close() : void
      {
         super.close();
         FarmStatsManager.count("Superbundle","Action","BundleScreen","close","","");
      }
   }
}

