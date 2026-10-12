package Widgets.Windows.MOTD
{
   import Classes.Animal;
   import Classes.ZItem.FarmItem;
   import Classes.util.MovieClipUtils;
   import Classes.util.ObjectUtil;
   import Classes.util.ZLocUtils;
   import Managers.TemplateUIUtility;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.ObjectPreviewFrame;
   import Widgets.Frames.ResourcePreviewFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.TextFields.FarmTextField;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   
   public class GenericSingleButtonWidgetMOTD extends CustomWindowMOTDBase
   {
      
      private var m_params:Object;
      
      protected var m_accept_bt:FarmAnimatedTextButton;
      
      private var m_storyMC:MovieClip;
      
      private const STORY_MC:String = "story_mc";
      
      private var m_frameNum:int = 1;
      
      protected var m_animationMc:ZwWidget;
      
      protected var m_animationTwoMc:ZwWidget;
      
      private var m_items:Array;
      
      private var m_previewFrame:Array;
      
      private var callbackrepositionfuncArray:Array;
      
      private const ANTIQUE_MUSEUM_BUILDING:String = "antiquemuseum";
      
      public function GenericSingleButtonWidgetMOTD(displayParams:Object = null)
      {
         var dialog:String = null;
         var motd:Object = null;
         var count:int = 0;
         var itemNameList:Array = null;
         var i:int = 0;
         this.m_items = new Array();
         this.m_previewFrame = new Array();
         this.callbackrepositionfuncArray = [this.repositionSlotPreviewFrame0,this.repositionSlotPreviewFrame1,this.repositionSlotPreviewFrame2,this.repositionSlotPreviewFrame3];
         this.m_params = displayParams;
         if(Boolean(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.MOTD)) && Boolean(this.m_params) && Boolean(this.m_params["textColor"]) && Boolean(this.m_params["dialogBackground"]))
         {
            if(this.m_params.hasOwnProperty("templateDialog"))
            {
               dialog = this.m_params["templateDialog"];
            }
            else
            {
               dialog = TemplateUIUtility.MOTD_TEMPLATE_SWF;
               this.m_params["dialog"] = dialog;
            }
         }
         else if(Boolean(displayParams) && Boolean(displayParams["dialog"]))
         {
            dialog = displayParams["dialog"];
         }
         else
         {
            motd = Global.player.currentMOTD;
            dialog = motd["dialog"];
         }
         if(displayParams.hasOwnProperty("itemList"))
         {
            count = int(displayParams["itemList"].item.length);
            itemNameList = new Array();
            for(i = 0; i < count; i++)
            {
               itemNameList.push(displayParams["itemList"]["item"][i]);
            }
            for(i = 0; i < itemNameList.length; i++)
            {
               this.m_items.push(Global.farmGameSettingsManager.getFarmItemByName(itemNameList[i]));
            }
         }
         super(dialog);
      }
      
      private function onBgLoad(dispObj:DisplayObject, info:Object = null) : void
      {
         m_window.mainWindow.addChildAt(dispObj,m_window.mainWindow.getChildIndex(m_window.mainWindow.loader_mc));
      }
      
      override protected function postLoadComplete() : void
      {
         var npcIcon:FarmIcon = null;
         var itemIcon:FarmIcon = null;
         var j:int = 0;
         var assetUrl:String = null;
         var bonusItem:FarmItem = null;
         var sizeScaleNumber:Number = NaN;
         var objectPreview:ObjectPreviewFrame = null;
         var titleText:String = null;
         var titleTextField:ZwTextField = null;
         var bodyTextField:ZwTextField = null;
         var body2TextField:ZwTextField = null;
         var body3TextField:ZwTextField = null;
         var isTemplateMotdSwf:Boolean = false;
         var shouldShowCloseButton:Boolean = false;
         var item:FarmItem = null;
         var scaleArray:Array = null;
         if(m_window.hasOwnProperty("mainWindow"))
         {
            MovieClipUtils.recursivePlay(m_window);
            addWidget(new ZwBaseWidget(m_window.mainWindow));
            if(m_window.mainWindow["accept_bt"])
            {
               this.m_accept_bt = addWidget(new FarmAnimatedTextButton(m_window.mainWindow.accept_bt,ZLocUtils.t_pk(m_currentMOTD["buttonText"]),this.onAccept)) as FarmAnimatedTextButton;
            }
            if(m_window.mainWindow[this.STORY_MC])
            {
               this.m_storyMC = m_window.mainWindow.story_mc as MovieClip;
               this.m_storyMC.visible = true;
            }
            if(Boolean(m_window.mainWindow["generic_mc"]) && Boolean(m_window.mainWindow.generic_mc["generic_bt"]))
            {
               this.m_accept_bt = addWidget(new FarmAnimatedTextButton(m_window.mainWindow.generic_mc.generic_bt,ZLocUtils.t_pk(m_currentMOTD["buttonText"]),this.onAccept)) as FarmAnimatedTextButton;
            }
            if(Boolean(m_window.mainWindow.hasOwnProperty("animation_mc")) && Boolean(this.m_params) && Boolean(this.m_params["animatedScene"]))
            {
               addWidget(new FarmIcon(m_window.mainWindow.animation_mc,Global.getAssetURL(this.m_params["animatedScene"])));
            }
            else if(m_window.mainWindow["animation_mc"])
            {
               this.m_animationMc = addWidget(new ZwWidget(m_window.mainWindow.animation_mc),true) as ZwWidget;
               if(this.m_animationMc)
               {
                  this.m_animationMc.element.play();
               }
            }
            if(Boolean(m_window["mainWindow"].hasOwnProperty("mc_NPC")) && Boolean(this.m_params["npcIconPath"]))
            {
               npcIcon = new FarmIcon(m_window["mainWindow"].mc_NPC) as FarmIcon;
               npcIcon.setIconSize(300,300);
               npcIcon.setSmoothing(true);
               npcIcon.loadIcon(Global.getAssetURL(this.m_params["npcIconPath"]));
            }
            if(Boolean(m_window["mainWindow"].hasOwnProperty("mc_EliteHorses")) && Boolean(this.m_params["iconItem"]))
            {
               itemIcon = new FarmIcon(m_window["mainWindow"].mc_EliteHorses) as FarmIcon;
               itemIcon.setIconSize(200,200);
               itemIcon.setSmoothing(true);
               itemIcon.loadIcon(Global.getAssetURL("assets/buildings/" + this.m_params["iconItem"] + "_icon_200.png"));
            }
            if(this.m_items)
            {
               for(j = 1; j <= this.m_items.length; j++)
               {
                  if(m_window["mainWindow"].hasOwnProperty("mc_EliteHorsesReward" + j))
                  {
                     this.m_previewFrame[j - 1] = addWidget(new ResourcePreviewFrame(m_window["mainWindow"]["mc_EliteHorsesReward" + j])) as ResourcePreviewFrame;
                     assetUrl = this.m_items[j - 1].imageRelativeUrl(Animal.STATE_FRONT_IDLE);
                     this.m_previewFrame[j - 1].load(assetUrl,this.m_items[j - 1].name + "_" + Animal.STATE_FRONT_IDLE,this.callbackrepositionfuncArray[j - 1]);
                     this.m_previewFrame[j - 1].visible = true;
                  }
               }
            }
            if(Boolean(m_window["mainWindow"].hasOwnProperty("mc_EliteHorsesBonus")) && Boolean(this.m_params["bonusAnimal"]))
            {
               bonusItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_params["bonusAnimal"]);
               if(bonusItem.getImageByName("frt_idle") != null)
               {
                  sizeScaleNumber = Math.min(2,7 / (bonusItem.sizeX + bonusItem.sizeY) / bonusItem.imageScale);
                  objectPreview = new ObjectPreviewFrame(m_window["mainWindow"].mc_EliteHorsesBonus,bonusItem,null,null,[200],Animal.STATE_FRONT_IDLE);
                  (objectPreview.element as MovieClip).filters = [];
                  addWidget(objectPreview,true);
               }
            }
            if(Boolean(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.MOTD)) && Boolean(m_window) && Boolean(m_window["mainWindow"]) && Boolean(m_window["mainWindow"]["buy_bt"]))
            {
               addWidget(new FarmAnimatedTextButton(m_window.mainWindow.buy_bt,ZLocUtils.t_pk(m_currentMOTD["buttonText"])),false);
               addWidget(new FarmAnimatedTextButton(m_window.mainWindow.share_bt,ZLocUtils.t_pk(m_currentMOTD["buttonText"])),false);
            }
            if(Boolean(m_window.mainWindow.hasOwnProperty("loader_mc")) && Boolean(this.m_params) && Boolean(this.m_params["dialogBackground"]))
            {
               addWidget(new FarmIcon(m_window.mainWindow.loader_mc,Global.getAssetURL(this.m_params["dialogBackground"])));
            }
            if(Boolean(m_window.mainWindow["title_tf"]) && m_currentMOTD.hasOwnProperty("title"))
            {
               titleText = ZLocUtils.t_pk(m_currentMOTD["title"]);
               if(titleText != "")
               {
                  titleTextField = new FarmTextField(m_window.mainWindow.title_tf,titleText);
                  addWidget(titleTextField);
                  TemplateUIUtility.applyTextScaling(titleTextField,TemplateUIUtility.MOTD);
                  if(Boolean(this.m_params) && Boolean(this.m_params["textColor"]))
                  {
                     TemplateUIUtility.applyDropShadowFilter(titleTextField,TemplateUIUtility.MOTD,this.m_params["textColor"]);
                  }
               }
            }
            if(Boolean(m_window.mainWindow["body_tf"]) && m_currentMOTD.hasOwnProperty("text"))
            {
               bodyTextField = new FarmTextField(m_window.mainWindow.body_tf,ZLocUtils.t_pk(m_currentMOTD["text"]));
               addWidget(bodyTextField);
               if(Boolean(this.m_params) && Boolean(this.m_params["textColor"]))
               {
                  TemplateUIUtility.applyTextColor(bodyTextField,TemplateUIUtility.MOTD,this.m_params["textColor"]);
               }
            }
            if(Boolean(m_window.mainWindow["body2_tf"]) && m_currentMOTD.hasOwnProperty("subtext"))
            {
               body2TextField = new FarmTextField(m_window.mainWindow.body2_tf,ZLocUtils.t_pk(m_currentMOTD["subtext"]));
               addWidget(body2TextField);
               if(Boolean(this.m_params) && Boolean(this.m_params["textColor"]))
               {
                  TemplateUIUtility.applyTextColor(body2TextField,TemplateUIUtility.MOTD,this.m_params["textColor"]);
               }
            }
            if(Boolean(m_window.mainWindow["body3_tf"]) && m_currentMOTD.hasOwnProperty("subsubtext"))
            {
               body3TextField = new FarmTextField(m_window.mainWindow.body3_tf,ZLocUtils.t_pk(m_currentMOTD["subsubtext"]));
               addWidget(body3TextField);
               if(Boolean(this.m_params) && Boolean(this.m_params["textColor"]))
               {
                  TemplateUIUtility.applyTextColor(body3TextField,TemplateUIUtility.MOTD,this.m_params["textColor"]);
               }
            }
            if(m_window.mainWindow.hasOwnProperty("back_mc"))
            {
               m_window.mainWindow.back_mc.visible = true;
               m_window.mainWindow.back_mc.gotoAndPlay(2);
            }
            if(m_window.mainWindow.hasOwnProperty("play_mc"))
            {
               addWidget(new ZwBaseWidget(m_window.mainWindow.play_mc));
               m_window.mainWindow.play_mc.gotoAndPlay(2);
               if(m_currentMOTD.hasOwnProperty("playAnimation") && m_currentMOTD["playAnimation"] == "true")
               {
                  MovieClipUtils.recursivePlay(m_window.mainWindow.play_mc);
               }
            }
            if(m_window.mainWindow.hasOwnProperty("close_bt"))
            {
               isTemplateMotdSwf = Boolean(this.m_params) && Boolean(this.m_params["dialog"]) && this.m_params["dialog"] == TemplateUIUtility.MOTD_TEMPLATE_SWF;
               shouldShowCloseButton = !isTemplateMotdSwf || Boolean(this.m_params["showCloseButton"]) && this.m_params["showCloseButton"] == "true";
               if(shouldShowCloseButton)
               {
                  m_closeButton = addWidget(new FarmButton(m_window.mainWindow.close_bt,this.onClose)) as FarmButton;
               }
               else
               {
                  m_window.mainWindow.close_bt.visible = false;
               }
            }
            if(Boolean(m_window.mainWindow.hasOwnProperty("icon_mc")) && Boolean(this.m_params) && this.m_params.hasOwnProperty("iconItem"))
            {
               item = Global.farmGameSettingsManager.getFarmItemByName(this.m_params["iconItem"]);
               if(item)
               {
                  scaleArray = this.m_params.hasOwnProperty("iconScale") ? [this.m_params["iconScale"]] : [2.5];
                  addWidget(new ObjectPreviewFrame(m_window.mainWindow.icon_mc,item,null,scaleArray));
               }
            }
            if(m_window.mainWindow.hasOwnProperty("link_mc"))
            {
               if(m_currentMOTD.hasOwnProperty("linkURL") && m_currentMOTD.hasOwnProperty("linkText"))
               {
                  addWidget(new FarmAnimatedTextButton(m_window.mainWindow.link_mc,ZLocUtils.t_pk(m_currentMOTD["linkText"]),this.onLinkClicked));
               }
            }
            if(m_window.mainWindow.hasOwnProperty("name_tf"))
            {
               addWidget(new FarmTextField(m_window.mainWindow.name_tf,Global.player.name));
            }
            if(ObjectUtil.pathExists(m_window,["mainWindow","legal_mc","generic_tf"]) && m_currentMOTD.hasOwnProperty("legal"))
            {
               addWidget(new FarmTextField(m_window.mainWindow.legal_mc.generic_tf,ZLocUtils.t_pk(m_currentMOTD["legal"])));
            }
         }
         if(m_window.hasOwnProperty("title_tf") && m_currentMOTD.hasOwnProperty("title"))
         {
            titleText = ZLocUtils.t_pk(m_currentMOTD["title"]);
            if(titleText != "")
            {
               titleTextField = new FarmTextField(m_window.title_tf,titleText);
               addWidget(titleTextField);
               TemplateUIUtility.applyTextScaling(titleTextField,TemplateUIUtility.MOTD);
               if(Boolean(this.m_params) && Boolean(this.m_params["textColor"]))
               {
                  TemplateUIUtility.applyDropShadowFilter(titleTextField,TemplateUIUtility.MOTD,this.m_params["textColor"]);
               }
            }
         }
         if(m_window.hasOwnProperty("body_tf") && m_currentMOTD.hasOwnProperty("text"))
         {
            bodyTextField = new FarmTextField(m_window.body_tf,ZLocUtils.t_pk(m_currentMOTD["text"]));
            addWidget(bodyTextField);
            if(Boolean(this.m_params) && Boolean(this.m_params["textColor"]))
            {
               TemplateUIUtility.applyTextColor(bodyTextField,TemplateUIUtility.MOTD,this.m_params["textColor"]);
            }
         }
      }
      
      private function repositionSlotPreviewFrame0() : void
      {
         var mc:MovieClip = this.m_previewFrame[0].exportedMovieClip;
         if(mc)
         {
            mc.y = -mc.height;
         }
      }
      
      private function repositionSlotPreviewFrame1() : void
      {
         var mc:MovieClip = this.m_previewFrame[1].exportedMovieClip;
         if(mc)
         {
            mc.y = -mc.height;
         }
      }
      
      private function repositionSlotPreviewFrame2() : void
      {
         var mc:MovieClip = this.m_previewFrame[2].exportedMovieClip;
         if(mc)
         {
            mc.y = -mc.height;
         }
      }
      
      private function repositionSlotPreviewFrame3() : void
      {
         var mc:MovieClip = this.m_previewFrame[3].exportedMovieClip;
         if(mc)
         {
            mc.y = -mc.height;
         }
      }
      
      private function onLinkClicked(event:Event) : void
      {
         navigateToURL(new URLRequest(ZLocUtils.t_pk(m_currentMOTD["linkURL"])),"_blank");
      }
      
      protected function onAccept(event:MouseEvent) : void
      {
         if(m_acceptCallback !== null)
         {
            m_acceptCallback.call();
         }
         this.close();
      }
      
      protected function onAcceptCashButton(event:Event) : void
      {
         if(m_acceptCallback !== null)
         {
            m_acceptCallback.call();
         }
         this.close();
      }
      
      override protected function onClose(event:Event) : void
      {
         if(m_cancelCallback !== null)
         {
            m_cancelCallback.call();
         }
         super.onClose(event);
      }
   }
}

