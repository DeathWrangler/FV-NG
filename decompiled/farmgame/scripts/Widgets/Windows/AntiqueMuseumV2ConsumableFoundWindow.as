package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.ImageLoader;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Managers.AntiqueMuseumV2Manager;
   import Managers.TemplateUIUtility;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.AntiqueMuseumV2ConsumableFoundFrame;
   import Widgets.Icons.FarmIcon;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class AntiqueMuseumV2ConsumableFoundWindow extends FarmWindow
   {
      
      private static const OFFSET_OPF_Y:int = -30;
      
      public static const FEATURE_NAME:String = "AntiqueMuseumV2";
      
      protected var m_featureName:String = null;
      
      private var m_reward:FarmItem = null;
      
      private var m_icon:FarmIcon = null;
      
      private var m_rewardIcon:FarmIcon = null;
      
      public var m_consumablesFrame:AntiqueMuseumV2ConsumableFoundFrame;
      
      private const ICON_PATH_PREFIX:String = "assets/dialogs/JulySideCarFeature_CanadianMuseum/";
      
      private const ICON_PATH_SUFFIX:String = "_icon_100.png";
      
      private var m_callback:Function = null;
      
      protected var title_tf:ZwTextField = null;
      
      protected var m_zoomingScale:int = 3;
      
      private var m_bgLoader:ImageLoader = null;
      
      private var m_bgIcon:DisplayObject = null;
      
      private var m_gift_mc:MovieClip = new MovieClip();
      
      private var m_rewardImage:String = null;
      
      private var m_isLBReward:Boolean = false;
      
      private var m_pieceName:String = "";
      
      private var m_countTf:ZwTextField;
      
      private var m_iconConsumables:FarmIcon;
      
      public function AntiqueMuseumV2ConsumableFoundWindow(dialogAsset:String, featureName:String, rewardItem:FarmItem = null, buttonCallback:Function = null, dialogBackground:String = null, rewardIcon:String = null, pieceName:String = "")
      {
         super(dialogAsset);
         this.m_reward = rewardItem;
         this.m_featureName = featureName;
         this.m_callback = buttonCallback;
         this.m_rewardImage = rewardIcon;
         this.m_pieceName = pieceName;
         if(dialogBackground != null)
         {
            this.m_bgLoader = ImageLoader.getInstance(Global.getAssetURL(dialogBackground));
            this.m_bgLoader.getContent(this.onBgLoad);
         }
      }
      
      private function onBgLoad(dispObj:DisplayObject, info:Object = null) : void
      {
         this.m_bgIcon = dispObj;
      }
      
      override protected function postLoadComplete() : void
      {
         var buttonCallback:Function = null;
         var consumables:MovieClip = null;
         var consumables0:MovieClip = null;
         super.postLoadComplete();
         var itemName:String = "";
         if(this.m_reward != null)
         {
            itemName = this.m_reward.friendlyTitle;
         }
         if(m_window != null)
         {
            if(m_window.hasOwnProperty("generic_tf"))
            {
               this.title_tf = addWidget(new ZwTextField(m_window["generic_tf"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "GenericText",{"itemName":itemName}))) as ZwTextField;
            }
            else if(m_window.hasOwnProperty("tittle_tf"))
            {
               this.title_tf = addWidget(new ZwTextField(m_window["tittle_tf"],"Natural History Museum")) as ZwTextField;
            }
            if(m_window.hasOwnProperty("body_tf"))
            {
               addWidget(new ZwTextField(m_window["body_tf"],"In your previous harvests you found these parts!"));
               if(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION))
               {
                  TemplateUIUtility.applyExpansionSubTextColor(m_window.body_tf);
               }
            }
            if(m_window.hasOwnProperty("close_bt"))
            {
               m_window.close_bt.visible = false;
            }
            if(m_window.hasOwnProperty("giftbox_mc"))
            {
               this.m_gift_mc = m_window.giftbox_mc;
               this.m_gift_mc.visible = true;
            }
            if(m_window.hasOwnProperty("consumables"))
            {
               consumables = m_window["consumables"] as MovieClip;
               consumables.visible = true;
               if(consumables.hasOwnProperty("consumable_0_mc"))
               {
                  consumables0 = consumables["consumable_0_mc"] as MovieClip;
                  consumables0.visible = true;
                  if(consumables0.hasOwnProperty("consumablecount_tf"))
                  {
                     this.m_countTf = new ZwTextField(consumables0["consumablecount_tf"],"0");
                     this.m_countTf.visible = true;
                  }
                  if(consumables0.hasOwnProperty("icon_mc"))
                  {
                     this.m_iconConsumables = addWidget(new FarmIcon(consumables0["icon_mc"])) as FarmIcon;
                     this.m_iconConsumables.visible = true;
                  }
               }
            }
            this.setUpConsumables();
            buttonCallback = new Function();
            if(m_window.hasOwnProperty("accept_bt"))
            {
               buttonCallback = this.onClose;
               if(this.m_callback != null)
               {
                  buttonCallback = this.m_callback;
               }
               addWidget(new FarmAnimatedTextButton(m_window["accept_bt"],"Awesome!",buttonCallback),true);
            }
         }
         if(this.manager)
         {
            if(this.manager.mainWindow)
            {
               this.manager.mainWindow.tintWindow();
               this.manager.mainWindow.enableInput = false;
            }
         }
      }
      
      private function get manager() : AntiqueMuseumV2Manager
      {
         return AntiqueMuseumV2Manager.getInstance();
      }
      
      override protected function onLoadComplete(event:Event) : void
      {
         super.onLoadComplete(event);
         if(m_closeButton)
         {
            m_closeButton.visible = false;
         }
      }
      
      override protected function onClose(event:Event) : void
      {
         if(this.manager.mainWindow)
         {
            this.manager.mainWindow.untintWindow();
            this.manager.mainWindow.enableInput = true;
         }
         super.close();
      }
      
      private function setUpConsumables() : void
      {
         var curr:int = 0;
         var url:String = null;
         var featureData:* = this.manager.getFeatureData();
         var pphGrantData:Array = featureData[this.manager.KEY_PPH_GRANT_ONLY];
         var index:int = this.manager.getCurrentPieceIndex();
         var pieceData:Array = this.manager.getActivePieces();
         var progress:int = int(pphGrantData[index]);
         if(progress > 0)
         {
            curr = this.manager.getTempPartsRequiredToComplete(pieceData[index]) + pphGrantData[index];
            if(progress > curr)
            {
               progress = curr;
            }
         }
         if(curr == 0)
         {
            progress = 0;
         }
         var pieceName:String = pieceData[index];
         var pieceProgress:int = progress;
         if(this.m_countTf)
         {
            this.m_countTf.text = pieceProgress.toString();
            this.m_countTf.visible = true;
         }
         if(this.m_iconConsumables)
         {
            url = this.ICON_PATH_PREFIX + this.manager.m_consumableCodeMapping[pieceName] + this.ICON_PATH_SUFFIX;
            this.m_iconConsumables.setIconSize(100,100);
            this.m_iconConsumables.loadIcon(url);
            this.m_iconConsumables.visible = true;
         }
      }
   }
}

