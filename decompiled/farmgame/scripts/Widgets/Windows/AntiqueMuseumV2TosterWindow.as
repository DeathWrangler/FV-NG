package Widgets.Windows
{
   import Managers.AntiqueMuseumV2Manager;
   import Managers.FarmStatsManager;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public class AntiqueMuseumV2TosterWindow extends AutoCloseToasterWindow
   {
      
      protected static const POPUP_NAME:String = "Simple Toaster";
      
      public static const FEATURE_NAME:String = "AntiqueMuseumV2";
      
      protected static const DEFAULT_TIME_TO_LIVE:Number = 20000;
      
      protected static const DEFAULT_ANIMATION_FRAME:int = 2;
      
      protected var m_featureName:String;
      
      protected var m_message:String;
      
      protected var m_title:String;
      
      protected var m_bgPath:String;
      
      protected var m_clickCallback:Function = null;
      
      protected var m_animatedClip:MovieClip = null;
      
      protected var m_animatedClipFrame:int;
      
      private var m_consumablesMC:MovieClip;
      
      private const ICON_PATH_PREFIX:String = "assets/dialogs/JulySideCarFeature_CanadianMuseum/";
      
      private const ICON_PATH_SUFFIX:String = "_icon_50.png";
      
      private var m_briefTf:ZwTextField;
      
      private var m_consumables0MC:MovieClip;
      
      private var m_countTf:ZwTextField;
      
      private var m_headerTf:ZwTextField;
      
      private var m_consumableIcon:FarmIcon;
      
      public function AntiqueMuseumV2TosterWindow(featureName:String, message:String, windowAssetPath:String, clickCallback:Function = null, toasterTime:Number = 0, title:String = "", bgPath:String = "", animationFrame:int = 2)
      {
         super(windowAssetPath);
         this.name = POPUP_NAME;
         this.m_featureName = featureName;
         this.m_message = message;
         this.m_title = title;
         this.m_bgPath = bgPath;
         this.m_clickCallback = clickCallback;
         this.m_animatedClipFrame = animationFrame;
         m_timeToLive = DEFAULT_TIME_TO_LIVE;
         if(toasterTime)
         {
            m_timeToLive = toasterTime;
         }
      }
      
      override protected function postLoadComplete() : void
      {
         if(m_window.hasOwnProperty("consumables"))
         {
            this.m_consumablesMC = m_window["consumables"] as MovieClip;
            this.m_consumablesMC.visible = true;
            if(this.m_consumablesMC.hasOwnProperty("antiquepartsbrief_tf"))
            {
               addWidget(this.m_briefTf = new ZwTextField(this.m_consumablesMC["antiquepartsbrief_tf"],this.m_message));
               this.m_briefTf.visible = true;
            }
            if(this.m_consumablesMC.hasOwnProperty("consumable_0_mc"))
            {
               this.m_consumables0MC = this.m_consumablesMC["consumable_0_mc"] as MovieClip;
               this.m_consumables0MC.visible = true;
               if(this.m_consumables0MC)
               {
                  if(this.m_consumables0MC.hasOwnProperty("c_icon"))
                  {
                     this.m_consumableIcon = new FarmIcon(this.m_consumables0MC["c_icon"]);
                  }
                  if(this.m_consumables0MC.hasOwnProperty("consumablecount_tf"))
                  {
                     addWidget(this.m_countTf = new ZwTextField(this.m_consumables0MC["consumablecount_tf"],""));
                  }
               }
            }
            if(this.m_consumablesMC.hasOwnProperty("consumable_header_tf"))
            {
               addWidget(this.m_headerTf = new ZwTextField(this.m_consumablesMC["consumable_header_tf"],"Parts Found"));
               this.m_headerTf.visible = true;
            }
         }
         this.setUpConsumables();
         FarmStatsManager.count("AntiqueMuseumV2","toaster","impressions");
      }
      
      protected function onHitBoxClick(event:MouseEvent) : void
      {
         if(event)
         {
            event.stopPropagation();
         }
         if(this.m_clickCallback != null)
         {
            this.m_clickCallback();
         }
         FarmStatsManager.count("AntiqueMuseumV2","toaster","clicks");
         close();
      }
      
      private function get manager() : AntiqueMuseumV2Manager
      {
         return AntiqueMuseumV2Manager.getInstance(FEATURE_NAME);
      }
      
      override public function show() : void
      {
         super.show();
         if(this.m_animatedClip != null)
         {
            this.m_animatedClip.gotoAndPlay(this.m_animatedClipFrame);
         }
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
         if(this.m_consumableIcon)
         {
            url = this.ICON_PATH_PREFIX + this.manager.m_consumableCodeMapping[pieceName] + this.ICON_PATH_SUFFIX;
            this.m_consumableIcon.setIconSize(50,50);
            this.m_consumableIcon.loadIcon(url);
            this.m_consumableIcon.visible = true;
         }
         if(this.m_briefTf)
         {
            this.m_briefTf.text = this.manager.m_consumableCodeNameMapping[pieceName];
         }
      }
   }
}

