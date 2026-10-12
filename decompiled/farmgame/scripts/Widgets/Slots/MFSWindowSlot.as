package Widgets.Slots
{
   import Classes.Constants.Experiments;
   import Classes.util.ZLocUtils;
   import Engine.Utilities;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public class MFSWindowSlot extends ZwSlotFrame
   {
      
      private static const ICON_SIZE:int = 30;
      
      private static const ICON_SIZE_LARGE:int = 100;
      
      private var m_clickCallback:Function = null;
      
      private var m_data:Object = null;
      
      private var m_selected:Boolean = true;
      
      private var m_activeBackground:ZwWidget = null;
      
      private var m_checkbox:ZwWidget = null;
      
      private var m_icon:FarmIcon = null;
      
      private var m_nameTextField:ZwTextField = null;
      
      private var m_level:ZwTextField = null;
      
      private var m_uid:String = null;
      
      private var m_sendButton:FarmAnimatedTextButton;
      
      public function MFSWindowSlot(element:DisplayObject, clickCallback:Function)
      {
         super(element);
         this.m_clickCallback = clickCallback;
         if(m_element.mc_active_bg)
         {
            this.m_activeBackground = addWidget(new ZwWidget(m_element.mc_active_bg)) as ZwWidget;
         }
         else if(m_element.standardBG_mc)
         {
            this.m_activeBackground = addWidget(new ZwWidget(m_element.standardBG_mc)) as ZwWidget;
         }
         if(m_element.mc_checkmark)
         {
            this.m_checkbox = addWidget(new ZwWidget(m_element.mc_checkmark)) as ZwWidget;
         }
         if(m_element.mc_fbprofile)
         {
            this.m_icon = addWidget(new FarmIcon(m_element.mc_fbprofile)) as FarmIcon;
            this.m_icon.setIconSize(ICON_SIZE,ICON_SIZE);
         }
         if(m_element.txt_name)
         {
            this.m_nameTextField = addWidget(new ZwTextField(m_element.txt_name," ")) as ZwTextField;
         }
         if(m_element.level_tf)
         {
            this.m_level = addWidget(new ZwTextField(m_element.level_tf," ")) as ZwTextField;
         }
         if(m_element.bt_send)
         {
            this.m_sendButton = addWidget(new FarmAnimatedTextButton(m_element.bt_send,"Send",this.onClick)) as FarmAnimatedTextButton;
            this.m_icon.setIconSize(ICON_SIZE_LARGE,ICON_SIZE_LARGE);
         }
         else
         {
            (m_element as MovieClip).addEventListener(MouseEvent.CLICK,this.onClick,false,0,true);
            (m_element as MovieClip).buttonMode = true;
         }
      }
      
      public function get data() : Object
      {
         return this.m_data;
      }
      
      public function set data(data:Object) : void
      {
         this.m_data = data;
      }
      
      public function get selected() : Boolean
      {
         return this.m_selected;
      }
      
      public function get uid() : String
      {
         return this.m_uid;
      }
      
      public function set selected(selected:Boolean) : void
      {
         this.m_activeBackground.visible = selected;
         this.m_checkbox.visible = this.m_selected = selected;
      }
      
      private function onClick(evt:MouseEvent) : void
      {
         this.m_activeBackground.visible = !this.m_selected;
         this.m_checkbox.visible = this.m_selected = !this.m_selected;
         if(this.m_clickCallback != null)
         {
            this.m_clickCallback();
         }
      }
      
      override public function populate(data:Object) : void
      {
         var maxLevelToDisplay:int = 0;
         super.populate(data);
         this.m_data = data;
         if(this.m_data)
         {
            this.m_uid = data["uid"];
            this.m_activeBackground.visible = true;
            this.m_checkbox.visible = this.m_selected = true;
            if(this.m_icon != null)
            {
               this.m_icon.loadIcon(data["pic_square"]);
               if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_FV_INTERSTITIAL_CLOSE_DELAY) == 4)
               {
                  this.m_icon.visible = false;
               }
               else
               {
                  this.m_icon.visible = true;
               }
            }
            this.m_nameTextField.text = data["name"];
            this.m_nameTextField.visible = true;
            maxLevelToDisplay = 1000;
            if(Global.flashHotParams["R2_NEIGHBOR_MAX_LEVEL_DISPLAY"] is int)
            {
               maxLevelToDisplay = int(Global.flashHotParams["R2_NEIGHBOR_MAX_LEVEL_DISPLAY"]);
            }
            if(data.hasOwnProperty("level") && maxLevelToDisplay > 0 && maxLevelToDisplay > data["level"] && Boolean(this.m_level))
            {
               this.m_level.text = ZLocUtils.t("Dialogs","MFSWindow_level",{"level":data["level"]});
               this.m_level.visible = true;
            }
            Utilities.toggleInputOnlySelf(m_element.txt_name,false);
            Utilities.toggleInputOnlyChildren(m_element as MovieClip,false);
            if(this.m_sendButton)
            {
               this.m_sendButton.visible = true;
            }
         }
      }
      
      override public function release() : void
      {
         (m_element as MovieClip).removeEventListener(MouseEvent.CLICK,this.onClick);
         this.m_clickCallback = null;
         this.m_data = null;
         this.m_activeBackground = null;
         this.m_checkbox = null;
         this.m_nameTextField = null;
         super.release();
      }
   }
}

