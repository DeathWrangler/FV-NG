package Widgets.Slots
{
   import Classes.Constants.MFSConstants;
   import Classes.util.ZLocUtils;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.display.DisplayObject;
   
   public class DeleteNeighborConfirmSlot extends ZwSlotFrame
   {
      
      private static const ICON_SIZE:int = 30;
      
      private var m_communityBG:ZwWidget = null;
      
      private var m_clickCallback:Function;
      
      private var m_data:Object;
      
      private var m_selected:Boolean = true;
      
      private var m_activeBackground:ZwWidget = null;
      
      private var m_checkbox:ZwWidget;
      
      private var m_icon:FarmIcon;
      
      private var m_nameTextField:ZwTextField;
      
      private var m_level:ZwTextField;
      
      public function DeleteNeighborConfirmSlot(element:DisplayObject, clickCallback:Function)
      {
         super(element);
         this.m_clickCallback = clickCallback;
         if(m_element.standardBG_mc)
         {
            this.m_activeBackground = addWidget(new ZwWidget(m_element.standardBG_mc)) as ZwWidget;
         }
         this.m_communityBG = addWidget(new ZwWidget(m_element.communityBG_mc)) as ZwWidget;
         this.m_icon = addWidget(new FarmIcon(m_element.mc_fbprofile)) as FarmIcon;
         this.m_icon.setIconSize(ICON_SIZE,ICON_SIZE);
         this.m_nameTextField = addWidget(new ZwTextField(m_element.txt_name," ")) as ZwTextField;
         if(m_element.level_tf)
         {
            this.m_level = addWidget(new ZwTextField(m_element.level_tf," ")) as ZwTextField;
         }
      }
      
      public function get data() : Object
      {
         return this.m_data;
      }
      
      override public function populate(data:Object) : void
      {
         super.populate(data);
         this.m_data = data;
         if(this.m_data)
         {
            if(this.m_data.hasOwnProperty(MFSConstants.NEIGHBOR_TYPE))
            {
               if(this.m_data[MFSConstants.NEIGHBOR_TYPE] == "n")
               {
                  this.m_activeBackground.visible = true;
               }
               else
               {
                  this.m_communityBG.visible = true;
               }
            }
            this.m_icon.loadIcon(data[MFSConstants.PIC_SQUARE]);
            this.m_icon.visible = true;
            this.m_nameTextField.text = data[MFSConstants.USER_NAME];
            this.m_nameTextField.visible = true;
            if(data.hasOwnProperty(MFSConstants.USER_LEVEL))
            {
               this.m_level.text = ZLocUtils.t("Dialogs","MFSWindow_level",{"level":data[MFSConstants.USER_LEVEL]});
               this.m_level.visible = true;
            }
         }
      }
      
      override public function release() : void
      {
         this.m_clickCallback = null;
         this.m_activeBackground = null;
         this.m_icon = null;
         this.m_data = null;
         this.m_nameTextField = null;
         super.release();
      }
   }
}

