package Widgets.Windows
{
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   
   public class GenericRewardWindow extends FarmWindow
   {
      
      protected static const POPUP_NAME:String = "genericRewardWindow";
      
      protected static const OKAY_BUTTON_NAME:String = "okay_bt";
      
      protected var m_onOkCallback:Function = null;
      
      protected var m_textFields:Object = null;
      
      protected var m_rewards:Array = null;
      
      protected var m_movieClips:Object = null;
      
      private var m_reward:FarmItem = null;
      
      public function GenericRewardWindow(dialogAsset:String, onOkCallback:Function, rewards:Array, textFields:Object = null, movieClips:Object = null, rewardItem:FarmItem = null)
      {
         super(dialogAsset);
         this.name = POPUP_NAME;
         this.m_onOkCallback = onOkCallback;
         this.m_rewards = rewards;
         this.m_textFields = textFields;
         this.m_movieClips = movieClips;
         this.m_reward = rewardItem;
      }
      
      override protected function postLoadComplete() : void
      {
         var rewardType:String = null;
         var textValue:String = null;
         var farmItem:FarmItem = null;
         var iconUrl:String = null;
         var name:String = null;
         var animatedMC:ZwBaseWidget = null;
         var textFieldName:String = null;
         var zlocKey:String = null;
         var text:String = null;
         var movieClipName:String = null;
         var baseWidget:ZwBaseWidget = null;
         super.postLoadComplete();
         for(var i:int = 0; i < this.m_rewards.length; i++)
         {
            rewardType = this.m_rewards[i].type;
            textValue = String(this.m_rewards[i].value);
            farmItem = Global.farmGameSettingsManager.getFarmItemByCode(textValue);
            if(farmItem != null)
            {
               textValue = ZLocUtils.tk_pk_asTitle(farmItem.friendlyName);
            }
            if(m_window.hasOwnProperty(rewardType + "_tf"))
            {
               addWidget(new ZwTextField(m_window[rewardType + "_tf"],String(this.m_rewards[i].value)));
            }
            if(m_window.hasOwnProperty(rewardType + "_mc"))
            {
               addWidget(new ZwBaseWidget(m_window[rewardType + "_mc"]));
            }
            if(Boolean(this.m_reward) && m_window.hasOwnProperty("icon_mc"))
            {
               iconUrl = this.m_reward.getImageByName(FarmItem.ICON_200);
               if(iconUrl == null)
               {
                  iconUrl = this.m_reward.getImageByName(FarmItem.ICON_FEED);
                  if(iconUrl == null)
                  {
                     iconUrl = this.m_reward.iconUrl;
                  }
               }
               addWidget(new FarmIcon(m_window["icon_mc"],iconUrl));
               name = this.m_reward.friendlyTitle;
               if(m_window.hasOwnProperty("subtitle_tf"))
               {
                  addWidget(new ZwTextField(m_window["subtitle_tf"],ZLocUtils.t("Dialogs","HarvestPopupSubtitletxt",{"name":name})));
               }
               if(m_window.hasOwnProperty("giftbox_mc"))
               {
                  m_window.giftbox_mc.visible = true;
               }
            }
            if(m_window.hasOwnProperty(rewardType + "Animated_mc"))
            {
               addWidget(animatedMC = new ZwBaseWidget(m_window[rewardType + "Animated_mc"]));
               (animatedMC.element as MovieClip).play();
            }
         }
         var okayButtonText:String = "Awesome";
         if(this.m_textFields)
         {
            for(textFieldName in this.m_textFields)
            {
               zlocKey = this.m_textFields[textFieldName];
               if(zlocKey)
               {
                  if(textFieldName == OKAY_BUTTON_NAME)
                  {
                     if(ZLocUtils.hasString("Dialogs",zlocKey))
                     {
                        okayButtonText = ZLocUtils.t("Dialogs",zlocKey);
                     }
                  }
                  else if(m_window[textFieldName] is TextField)
                  {
                     text = ZLocUtils.hasString("Dialogs",zlocKey) ? ZLocUtils.t("Dialogs",zlocKey) : zlocKey;
                     addWidget(new ZwTextField(m_window[textFieldName],text));
                  }
               }
            }
         }
         if(m_window[OKAY_BUTTON_NAME])
         {
            addWidget(new FarmAnimatedTextButton(m_window[OKAY_BUTTON_NAME],okayButtonText,this.onOkButtonClick));
         }
         if(this.m_movieClips)
         {
            for(movieClipName in this.m_movieClips)
            {
               if(m_window.hasOwnProperty(movieClipName))
               {
                  addWidget(baseWidget = new ZwBaseWidget(m_window[movieClipName]));
                  if(movieClipName.indexOf("animated") != -1)
                  {
                     (baseWidget.element as MovieClip).play();
                  }
               }
            }
         }
      }
      
      override protected function release() : void
      {
         this.m_onOkCallback = null;
         this.m_rewards = null;
         this.m_textFields = null;
         this.m_movieClips = null;
         super.release();
      }
      
      private function onOkButtonClick(event:MouseEvent) : void
      {
         if(this.m_onOkCallback != null)
         {
            this.m_onOkCallback();
         }
         close();
      }
   }
}

