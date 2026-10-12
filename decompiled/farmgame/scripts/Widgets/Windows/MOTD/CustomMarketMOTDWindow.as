package Widgets.Windows.MOTD
{
   import Classes.Constants.Experiments;
   import Classes.Constants.ZLocConstants;
   import Classes.ImageLoader;
   import Classes.ZItem.FarmItem;
   import Classes.util.MovieClipUtils;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Engine.Managers.ErrorManager;
   import Managers.FarmStatsManager;
   import Managers.TemplateUIUtility;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Frames.ObjectPreviewFrame;
   import Widgets.TextFields.FarmTextField;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   
   public class CustomMarketMOTDWindow extends CustomWindowMOTDBase
   {
      
      private var m_marketItems:Array = new Array();
      
      private var m_dialogBackground:String;
      
      private var m_slotBGIcon:DisplayObject;
      
      public function CustomMarketMOTDWindow(params:Object = null)
      {
         var assetPath:String = null;
         if(Boolean(params) && Boolean(params.hasOwnProperty("marketItem")) && params.hasOwnProperty("windowAsset"))
         {
            if(params.marketItem is Array)
            {
               this.m_marketItems = params.marketItem;
            }
            else
            {
               this.m_marketItems.push(params.marketItem);
            }
            this.m_dialogBackground = params.dialogBackground;
            assetPath = params.windowAsset;
         }
         else
         {
            ErrorManager.addError("Custom Market MOTD missing required customWindowParams tags: windowAsset, marketItem");
         }
         super(assetPath);
      }
      
      override protected function postLoadComplete() : void
      {
         var bgImagePath:String = null;
         var item:FarmItem = null;
         super.postLoadComplete();
         var templatized:Boolean = TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION);
         var textButton:String = ZLocUtils.t("Dialogs","MOTD_Market_Accept");
         if(m_window)
         {
            MovieClipUtils.recursivePlay(m_window);
         }
         if(m_window.okay_bt)
         {
            addWidget(new FarmAnimatedTextButton(m_window.okay_bt,textButton,this.onClickAccept));
         }
         if(Global.eosManager.getEosVariant(Experiments.EXPERIMENT_FLASH_MOTD_EXP) >= 2)
         {
            if(m_closeButton)
            {
               m_closeButton.visible = true;
            }
         }
         else if(m_closeButton)
         {
            m_closeButton.visible = false;
         }
         if(m_window.hasOwnProperty("loader_mc") && Boolean(this.m_dialogBackground))
         {
            ImageLoader.getInstance(Global.getAssetURL(this.m_dialogBackground)).getContent(this.onBgLoad);
         }
         if(m_window.hasOwnProperty("mc_WorldScoreIcon"))
         {
            bgImagePath = Global.worldSettingsManager.getSlotBGImagePath("worldScoreIcon");
            if(bgImagePath)
            {
               ImageLoader.getInstance(Global.getAssetURL(bgImagePath)).getContent(this.onSlotUrlLoaded);
            }
         }
         if(m_window.hasOwnProperty("title_tf"))
         {
            addWidget(new FarmTextField(m_window.title_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,m_currentMOTD.motdSeenFlag + "_title")));
            if(templatized)
            {
               TemplateUIUtility.applyExpansionTextColor(m_window.title_tf);
               TemplateUIUtility.applyExpansionBevelFilter(m_window.title_tf);
               TemplateUIUtility.applyExpansionDropShadowFilter(m_window.title_tf);
            }
         }
         if(m_window.hasOwnProperty("subheader_tf"))
         {
            addWidget(new FarmTextField(m_window.subheader_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,m_currentMOTD.motdSeenFlag + "_description")));
            if(templatized)
            {
               TemplateUIUtility.applyExpansionGlowFilter(m_window.subheader_tf);
            }
         }
         if(m_window.hasOwnProperty("body_tf"))
         {
            addWidget(new FarmTextField(m_window.body_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,m_currentMOTD.motdSeenFlag + "_description")));
            if(templatized)
            {
               TemplateUIUtility.applyExpansionSubTextColor(m_window.body_tf);
            }
         }
         if(m_window.hasOwnProperty("buildable_tf"))
         {
            addWidget(new FarmTextField(m_window.buildable_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,m_currentMOTD.motdSeenFlag + "_buildable")));
            if(templatized)
            {
               TemplateUIUtility.applyExpansionTextColor(m_window.buildable_tf);
            }
         }
         if(m_window.hasOwnProperty("treasure_tf"))
         {
            addWidget(new FarmTextField(m_window.treasure_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,m_currentMOTD.motdSeenFlag + "_treasure")));
            if(templatized)
            {
               TemplateUIUtility.applyExpansionTextColor(m_window.treasure_tf);
            }
         }
         if(m_window.hasOwnProperty("avail_tf"))
         {
            addWidget(new FarmTextField(m_window.avail_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,m_currentMOTD.motdSeenFlag + "_avail")));
            if(templatized)
            {
               TemplateUIUtility.applyExpansionGlowFilter(m_window.avail_tf);
            }
         }
         if(m_window.hasOwnProperty("points_tf"))
         {
            addWidget(new FarmTextField(m_window.points_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,m_currentMOTD.motdSeenFlag + "_points")));
            if(templatized)
            {
               TemplateUIUtility.applyExpansionSubTextColor(m_window.points_tf);
            }
         }
         if(m_window.hasOwnProperty("vehicle1"))
         {
            addWidget(new FarmTextField(m_window.vehicle1,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"vehicle1")));
            if(templatized)
            {
               TemplateUIUtility.applyExpansionGlowFilter(m_window.vehicle1);
            }
         }
         if(m_window.hasOwnProperty("vehicle2"))
         {
            addWidget(new FarmTextField(m_window.vehicle2,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"vehicle2")));
            if(templatized)
            {
               TemplateUIUtility.applyExpansionGlowFilter(m_window.vehicle2);
            }
         }
         if(m_window.hasOwnProperty("vehicle3"))
         {
            addWidget(new FarmTextField(m_window.vehicle3,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"vehicle3")));
            if(templatized)
            {
               TemplateUIUtility.applyExpansionGlowFilter(m_window.vehicle3);
            }
         }
         if(m_window.hasOwnProperty("vehicle4"))
         {
            addWidget(new FarmTextField(m_window.vehicle4,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"vehicle4")));
            if(templatized)
            {
               TemplateUIUtility.applyExpansionGlowFilter(m_window.vehicle4);
            }
         }
         if(m_window.hasOwnProperty("vehicle5"))
         {
            addWidget(new FarmTextField(m_window.vehicle5,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"vehicle5")));
            if(templatized)
            {
               TemplateUIUtility.applyExpansionGlowFilter(m_window.vehicle5);
            }
         }
         for(var i:int = 0; i < this.m_marketItems.length; i++)
         {
            if(m_window.hasOwnProperty("mc_Vehicle" + i.toString()))
            {
               item = Global.farmGameSettingsManager.getFarmItemByName(this.m_marketItems[i]);
               if(item != null)
               {
                  addWidget(new ObjectPreviewFrame(m_window["mc_Vehicle" + i.toString()],item));
               }
            }
         }
      }
      
      private function onBgLoad(dispObj:DisplayObject, info:Object = null) : void
      {
         m_window.addChildAt(dispObj,m_window.getChildIndex(m_window.loader_mc));
      }
      
      private function onSlotUrlLoaded(dispObj:DisplayObject, info:Object = null) : void
      {
         this.m_slotBGIcon = dispObj;
         if(Boolean(this.m_slotBGIcon) && Boolean(m_window))
         {
            m_window["mc_WorldScoreIcon"].addChild(this.m_slotBGIcon);
            m_window["mc_WorldScoreIcon"].visible = true;
         }
      }
      
      override public function show() : void
      {
         if(m_closeButton)
         {
            if(Global.eosManager.getEosVariant(Experiments.EXPERIMENT_FLASH_MOTD_EXP) >= 2)
            {
               m_closeButton.visible = true;
            }
         }
         else if(m_closeButton)
         {
            m_closeButton.visible = false;
         }
         super.show();
      }
      
      private function onClickAccept(event:MouseEvent) : void
      {
         if(m_currentMOTD.hasOwnProperty("motdSeenFlag"))
         {
            FarmStatsManager.count("MOTD","OK",m_currentMOTD.motdSeenFlag);
         }
         UI.displayMiniMarketDialog(this.m_marketItems,"motd","seed",null,true,false,false,true);
         super.onClose(event);
      }
   }
}

