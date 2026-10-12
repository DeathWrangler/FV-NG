package Widgets.Windows
{
   import Classes.Animal;
   import Classes.ImageLoader;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Managers.TemplateUIUtility;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.ObjectPreviewFrame;
   import Widgets.Frames.ResourcePreviewFrame;
   import Widgets.Icons.FarmIcon;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   
   public class AOEBuildableRewardWindow extends FarmWindow
   {
      
      private var m_item:FarmItem = null;
      
      private var m_AOESourceName:String = "";
      
      protected var m_iconPreview:ResourcePreviewFrame;
      
      private var postAOEIcon:String = "";
      
      private var m_dialogBackground:String = "";
      
      private var m_bgLoader:ImageLoader = null;
      
      private var m_bgIcon:DisplayObject = null;
      
      private var m_gift_mc:MovieClip = new MovieClip();
      
      public function AOEBuildableRewardWindow(swf:String, itemName:String, AOEItemName:String, PostAOEIcon:String, dialogBackground:String = "")
      {
         super(swf);
         this.m_item = Global.farmGameSettingsManager.getFarmItemByName(itemName);
         this.m_dialogBackground = dialogBackground;
         this.m_AOESourceName = AOEItemName;
         this.postAOEIcon = PostAOEIcon;
         if(this.m_dialogBackground != null)
         {
            this.m_bgLoader = ImageLoader.getInstance(Global.getAssetURL(this.m_dialogBackground));
            this.m_bgLoader.getContent(this.onBgLoad);
         }
      }
      
      private function onBgLoad(dispObj:DisplayObject, info:Object = null) : void
      {
         this.m_bgIcon = dispObj;
      }
      
      override protected function postLoadComplete() : void
      {
         var subtitleText:String = null;
         var buttonText:String = null;
         var titleText:String = null;
         var title:String = null;
         var sizeScale:Number = NaN;
         var objectPreviewFrame:ObjectPreviewFrame = null;
         var icon:FarmIcon = null;
         var url:String = null;
         var descriptionText:String = null;
         var sideText:String = null;
         var completeText:String = null;
         super.postLoadComplete();
         if(m_window.hasOwnProperty("share_bt"))
         {
            buttonText = ZLocUtils.hasString("Dialogs",this.m_item.name + "_accept") ? ZLocUtils.t("Dialogs",this.m_item.name + "_accept") : ZLocUtils.t("Dialogs","AOERewardWindow_accept");
            addWidget(new FarmAnimatedTextButton(m_window.share_bt,buttonText,onClose),true);
         }
         if(m_window.hasOwnProperty("generic_tf"))
         {
            titleText = ZLocUtils.hasString("Dialogs",this.m_item.name + "_AOERewardWindow_title") ? ZLocUtils.t("Dialogs",this.m_item.name + "_AOERewardWindow_title") : ZLocUtils.t("Dialogs","AOERewardWindow_title");
            addWidget(new ZwTextField(m_window.generic_tf,titleText),true);
         }
         if(m_window.hasOwnProperty("generic2_tf"))
         {
            subtitleText = ZLocUtils.hasString("Dialogs",this.m_item.name + "_AOERewardWindow_subtitle") ? ZLocUtils.t("Dialogs",this.m_item.name + "_AOERewardWindow_subtitle",{"itemName":ZLocUtils.tk_pk_asTitle(this.m_item.friendlyName)}) : ZLocUtils.t("Dialogs","AOERewardWindow_subtitle",{"itemName":ZLocUtils.tk_pk_asTitle(this.m_item.friendlyName)});
            addWidget(new ZwTextField(m_window.generic2_tf,subtitleText),true);
         }
         else if(m_window.hasOwnProperty("subtext1_tf"))
         {
            subtitleText = ZLocUtils.hasString("Dialogs",this.m_item.name + "_AOERewardWindow_subtitle") ? ZLocUtils.t("Dialogs",this.m_item.name + "_AOERewardWindow_subtitle",{"itemName":ZLocUtils.tk_pk_asTitle(this.m_item.friendlyName)}) : ZLocUtils.t("Dialogs","AOERewardWindow_subtitle",{"itemName":ZLocUtils.tk_pk_asTitle(this.m_item.friendlyName)});
            addWidget(new ZwTextField(m_window.subtext1_tf,subtitleText),true);
            TemplateUIUtility.applyExpansionSubTextColor(m_window.subtext1_tf);
         }
         if(m_window.hasOwnProperty("title_tf"))
         {
            title = "Congrats!";
            addWidget(new ZwTextField(m_window.title_tf,title),true);
            TemplateUIUtility.applyExpansionTextColor(m_window.title_tf);
            TemplateUIUtility.applyExpansionBevelFilter(m_window.title_tf);
            TemplateUIUtility.applyExpansionDropShadowFilter(m_window.title_tf);
         }
         if(m_window.hasOwnProperty("giftbox_mc"))
         {
            this.m_gift_mc = m_window.giftbox_mc;
            this.m_gift_mc.visible = true;
         }
         if(m_window.hasOwnProperty("reward_mc"))
         {
            if(this.m_item.getImageByName("frt_idle") != null)
            {
               sizeScale = Math.min(2,7 / (this.m_item.sizeX + this.m_item.sizeY) / this.m_item.imageScale);
               objectPreviewFrame = new ObjectPreviewFrame(m_window.reward_mc,this.m_item,null,null,[200],Animal.STATE_FRONT_IDLE);
               (objectPreviewFrame.element as MovieClip).filters = [];
               addWidget(objectPreviewFrame,true);
            }
            else
            {
               icon = addWidget(new FarmIcon(m_window.reward_mc)) as FarmIcon;
               icon.setIconSize(200,200);
               icon.setSmoothing(true);
               url = this.m_item.imageRelativeUrl("feed");
               if(!url)
               {
                  url = this.m_item.icon;
               }
               icon.loadIcon(url);
            }
         }
         if(m_window.hasOwnProperty("generic3_tf"))
         {
            descriptionText = ZLocUtils.hasString("Dialogs",this.m_item.name + "_AOERewardWindow_description") ? ZLocUtils.t("Dialogs",this.m_item.name + "_AOERewardWindow_description",{"AOESource":this.m_AOESourceName}) : ZLocUtils.t("Dialogs","AOERewardWindow_description",{"AOESource":this.m_AOESourceName});
            addWidget(new ZwTextField(m_window.generic3_tf,descriptionText),true);
         }
         if(m_window.hasOwnProperty("generic4_tf"))
         {
            sideText = ZLocUtils.hasString("Dialogs",this.m_item.name + "_AOERewardWindow_sideText") ? ZLocUtils.t("Dialogs",this.m_item.name + "_AOERewardWindow_sideText") : ZLocUtils.t("Dialogs","AOERewardWindow_sideText");
            addWidget(new ZwTextField(m_window.generic4_tf,sideText),true);
         }
         if(m_window.hasOwnProperty("generic5_tf"))
         {
            completeText = ZLocUtils.hasString("Dialogs",this.m_item.name + "_AOERewardWindow_completeText") ? ZLocUtils.t("Dialogs",this.m_item.name + "_AOERewardWindow_completeText") : ZLocUtils.t("Dialogs","AOERewardWindow_completeText");
            addWidget(new ZwTextField(m_window.generic5_tf,completeText),true);
         }
         if(Boolean(m_window.mc_RewardDialog) && Boolean(this.m_bgIcon))
         {
            m_window.addChildAt(this.m_bgIcon,m_window.getChildIndex(m_window.mc_RewardDialog));
         }
      }
   }
}

