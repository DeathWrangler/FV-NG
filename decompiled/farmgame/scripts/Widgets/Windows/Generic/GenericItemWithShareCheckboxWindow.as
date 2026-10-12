package Widgets.Windows.Generic
{
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.FarmWindow;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class GenericItemWithShareCheckboxWindow extends FarmWindow
   {
      
      private static const ICON_SIZE:int = 100;
      
      private var m_checkMark:MovieClip;
      
      private var m_checkBox:FarmAnimatedButton;
      
      private var m_params:GenericItemWithShareCheckboxWindowParams;
      
      public function GenericItemWithShareCheckboxWindow(params:GenericItemWithShareCheckboxWindowParams)
      {
         this.m_params = params;
         if(params.dialogAssetUrl)
         {
            super(params.dialogAssetUrl);
         }
         else
         {
            GlobalEngine.assert(false,"Params object missing dialog asset url.");
         }
      }
      
      override protected function postLoadComplete() : void
      {
         var icon:FarmIcon = null;
         super.postLoadComplete();
         addWidget(new ZwTextField(m_window.title_tf,this.m_params.titleText));
         addWidget(new ZwTextField(m_window.item_tf,this.m_params.itemText));
         addWidget(new ZwTextField(m_window.info_tf,this.m_params.infoText));
         addWidget(new FarmAnimatedTextButton(m_window.accept_bt,this.m_params.buttonText,this.onAcceptClick));
         if(this.m_params.item)
         {
            icon = addWidget(new FarmIcon(m_window.icon_mc)) as FarmIcon;
            icon.setIconSize(ICON_SIZE,ICON_SIZE);
            icon.loadIcon(this.m_params.item.iconUrl);
         }
         else
         {
            GlobalEngine.assert(false,"Params object missing item.");
         }
         if(m_window.hasOwnProperty("checkbox_tf"))
         {
            this.m_checkMark = m_window.checkMark_mc as MovieClip;
            this.m_checkMark.buttonMode = true;
            this.m_checkMark.mouseEnabled = true;
            this.m_checkMark.visible = true;
            this.m_checkMark.addEventListener(MouseEvent.CLICK,this.onCheckBoxClick);
            this.m_checkBox = addWidget(new FarmAnimatedButton(m_window.checkBox_mc,this.onCheckBoxClick)) as FarmAnimatedButton;
            addWidget(new ZwTextField(m_window.checkbox_tf,this.m_params.shareText));
         }
      }
      
      override protected function onClose(event:Event) : void
      {
         if(this.m_params.closeCallback != null)
         {
            this.m_params.closeCallback(false);
         }
         super.onClose(event);
      }
      
      override protected function release() : void
      {
         this.m_checkBox = null;
         this.m_checkMark = null;
         this.m_params = null;
         super.release();
      }
      
      public function onCheckBoxClick(event:MouseEvent) : void
      {
         this.m_checkMark.visible = !this.m_checkMark.visible;
      }
      
      public function onAcceptClick(event:MouseEvent) : void
      {
         var isChecked:Boolean = Boolean(this.m_checkMark) && this.m_checkMark.visible;
         if(isChecked)
         {
            if(Boolean(this.m_params.feedAction) && Boolean(this.m_params.feedBundleData))
            {
               GlobalEngine.socialNetwork.publishFeedStory(this.m_params.feedAction,this.m_params.feedBundleData,[],false);
            }
         }
         if(this.m_params.closeCallback != null)
         {
            this.m_params.closeCallback(isChecked,this.m_params.extraData);
         }
         close();
      }
   }
}

