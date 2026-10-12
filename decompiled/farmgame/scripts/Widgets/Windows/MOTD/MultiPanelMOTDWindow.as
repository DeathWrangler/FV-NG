package Widgets.Windows.MOTD
{
   import Classes.Constants.Experiments;
   import Classes.Quest.PrerequisiteUtility;
   import Classes.util.ZLocUtils;
   import Managers.FeatureMessagingManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import gs.TweenLite;
   
   public class MultiPanelMOTDWindow extends CustomWindowMOTDBase
   {
      
      private var m_featurePanels:Array;
      
      private var m_textPrefix:String = "MultiPaneMOTDWindow";
      
      private var m_rolloversToRemove:Array;
      
      public function MultiPanelMOTDWindow(displayParams:Object = null)
      {
         var dialogAsset:String = null;
         var allFeaturePanels:Array = null;
         var panels:Array = null;
         var prereq:Object = null;
         var panel:Object = null;
         var runtimeFeatureString:String = null;
         var runtimeFeatureArray:Array = null;
         var featureName:String = null;
         var feature:Object = null;
         var variant:int = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_PERSONALIZATION);
         if(displayParams)
         {
            if(displayParams.hasOwnProperty("dialog"))
            {
               dialogAsset = dialogAsset["dialog"];
            }
            else
            {
               dialogAsset = this.getDialogPath(variant);
            }
            allFeaturePanels = new Array();
            if(displayParams.hasOwnProperty("panels"))
            {
               panels = displayParams["panels"]["panel"];
               for each(panel in panels)
               {
                  if(panel.prereq)
                  {
                     prereq = Global.farmGameSettingsManager.getPrereqByName(panel.prereq);
                     if(prereq)
                     {
                        if(PrerequisiteUtility.isPrerequisiteMet(prereq))
                        {
                           allFeaturePanels[panel.name] = panel;
                        }
                     }
                  }
                  else
                  {
                     allFeaturePanels[panel.name] = panel;
                  }
               }
               if(variant == 7)
               {
                  runtimeFeatureString = Global.flashHotParams["MULTIPANEL_MOTD_v2"] as String;
               }
               else
               {
                  runtimeFeatureString = Global.flashHotParams["MULTIPANEL_MOTD_v1"] as String;
               }
               this.m_featurePanels = [];
               if(runtimeFeatureString)
               {
                  runtimeFeatureArray = runtimeFeatureString.split(",");
                  for each(featureName in runtimeFeatureArray)
                  {
                     if(allFeaturePanels.hasOwnProperty(featureName))
                     {
                        this.m_featurePanels.push(allFeaturePanels[featureName]);
                     }
                  }
               }
               else
               {
                  for each(feature in allFeaturePanels)
                  {
                     this.m_featurePanels.push(feature);
                  }
               }
            }
            if(displayParams.hasOwnProperty("textPrefix"))
            {
               this.m_textPrefix = displayParams["textPrefix"];
            }
         }
         super(dialogAsset);
      }
      
      private function getDialogPath(variant:int) : String
      {
         var result:String = null;
         switch(variant)
         {
            case 6:
            case 7:
            case 10:
               result = "assets/dialogs/FV_ChooseBuildable_4up.swf";
               break;
            case 8:
               result = "assets/dialogs/FV_ChooseBuildable_2up.swf";
               break;
            case 9:
            default:
               result = "assets/dialogs/FV_ChooseBuildable_6up.swf";
         }
         return result;
      }
      
      override protected function postLoadComplete() : void
      {
         var panelElement:MovieClip = null;
         var panelFrame:ZwFrame = null;
         var panelConfig:Object = null;
         var rolloverFunc:Function = null;
         var icon:FarmIcon = null;
         super.postLoadComplete();
         addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t("Dialogs",this.m_textPrefix + "_title")));
         addWidget(new ZwTextField(m_window.subTitle_tf,ZLocUtils.t("Dialogs",this.m_textPrefix + "_subTitle")));
         var panelCount:int = 0;
         this.m_rolloversToRemove = [];
         while(Boolean(m_window["cell" + panelCount + "_mc"]) && this.m_featurePanels.length > panelCount)
         {
            panelElement = m_window["cell" + panelCount + "_mc"];
            panelConfig = this.m_featurePanels[panelCount];
            panelFrame = new ZwFrame(panelElement);
            panelFrame.addWidget(new ZwTextField(panelElement.name_tf,ZLocUtils.tk_pk_asTitle(panelConfig.title)));
            if(FeatureMessagingManager.getInstance().isFeatureProgressComplete(panelConfig.actionVar))
            {
               panelFrame.addWidget(new ZwFrame(panelElement.complete_mc));
               panelFrame.addWidget(new ZwTextField(panelElement.complete_mc.inProgress_tf,ZLocUtils.t("Dialogs",this.m_textPrefix + "_Completed")));
            }
            else
            {
               panelFrame.addWidget(new FarmAnimatedTextButton(panelElement.place_bt,this.getActionText(panelConfig),this.generateActionCallback(panelConfig)));
            }
            icon = new FarmIcon(panelElement.MOTD_mc);
            icon.loadIcon(panelConfig.image);
            panelFrame.addWidget(icon);
            panelFrame.addWidget(new ZwFrame(panelElement.rollover_mc));
            panelElement.rollover_mc.alpha = 0;
            panelFrame.addWidget(new ZwTextField(panelElement.rollover_mc.rolloverText_tf,ZLocUtils.tk_pk_asTitle(panelConfig.desc)));
            rolloverFunc = this.generateOnOver(panelElement.rollover_mc);
            panelFrame.registerEventListener(MouseEvent.MOUSE_OVER,rolloverFunc);
            this.m_rolloversToRemove.push(this.generateRemoveRollover(panelFrame,MouseEvent.MOUSE_OVER,rolloverFunc));
            rolloverFunc = this.generateOnOut(panelElement.rollover_mc);
            panelFrame.registerEventListener(MouseEvent.MOUSE_OUT,rolloverFunc);
            this.m_rolloversToRemove.push(this.generateRemoveRollover(panelFrame,MouseEvent.MOUSE_OUT,rolloverFunc));
            addWidget(panelFrame);
            panelCount++;
         }
      }
      
      private function generateRemoveRollover(panel:ZwFrame, eventType:String, func:Function) : Function
      {
         return function():void
         {
            panel.unregisterEventListener(eventType,func);
         };
      }
      
      private function generateActionCallback(panelConfig:Object) : Function
      {
         return function():void
         {
            var fromMarket:* = undefined;
            if(m_acceptCallback !== null)
            {
               m_acceptCallback.call();
            }
            switch(panelConfig.action)
            {
               case "openFeatureOrPlace":
                  if(FeatureMessagingManager.getInstance().isFeatureInitialized(panelConfig.actionVar))
                  {
                     FeatureMessagingManager.getInstance().openFeatureUI(panelConfig.actionVar);
                  }
                  else
                  {
                     fromMarket = Global.player.getGiftCountForItem(panelConfig.itemName) <= 0;
                     Global.world.enterForcePlaceMode(panelConfig.itemName,fromMarket,0,true,!fromMarket);
                  }
                  close();
            }
         };
      }
      
      private function getActionText(panelConfig:Object) : String
      {
         var result:String = null;
         switch(panelConfig.action)
         {
            case "openFeatureOrPlace":
               if(FeatureMessagingManager.getInstance().isFeatureInitialized(panelConfig.actionVar))
               {
                  result = ZLocUtils.t("Dialogs","Continue");
               }
               else
               {
                  result = ZLocUtils.t("Dialogs","PlaceNow");
               }
         }
         return result;
      }
      
      private function generateOnOver(rollover:Object) : Function
      {
         return function(e:MouseEvent):void
         {
            TweenLite.to(rollover,0.25,{"alpha":1});
         };
      }
      
      private function generateOnOut(rollover:Object) : Function
      {
         return function(e:MouseEvent):void
         {
            TweenLite.to(rollover,0.25,{"alpha":0});
         };
      }
      
      override protected function release() : void
      {
         var func:Function = null;
         for each(func in this.m_rolloversToRemove)
         {
            func();
         }
         super.release();
      }
   }
}

