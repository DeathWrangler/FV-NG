package Widgets.Slots
{
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Managers.FaceOffManager;
   import Managers.FarmGameSettingsManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.ObjectPreviewFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.FaceOffWindow;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class FaceOffVersusSlot extends ZwSlotFrame
   {
      
      private var m_item:FarmItem;
      
      private var m_window:FaceOffWindow;
      
      private var m_facePileVariant:int;
      
      private var m_facePiles:Array;
      
      public function FaceOffVersusSlot(element:MovieClip, itemName:String, window:FaceOffWindow)
      {
         super(element);
         this.m_window = window;
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            this.m_item = Global.farmGameSettingsManager.getFarmItemByName(itemName);
         }
         else
         {
            this.m_item = new FarmItem(Global.farmGameSettingsManager.getItemXMLByName(itemName));
         }
         this.m_facePileVariant = Global.experimentManager.getExperimentVariant("fv_face_off_facepile");
         if(m_element["back_mc"])
         {
            addWidget(new ZwBaseWidget(m_element.back_mc));
         }
         if(Boolean(m_element["image_mc"]) && Boolean(this.m_item))
         {
            addWidget(new ObjectPreviewFrame(m_element.image_mc,this.m_item));
         }
         if(Boolean(m_element["itemTitle_tf"]) && Boolean(this.m_item))
         {
            addWidget(new ZwTextField(m_element.itemTitle_tf,ZLocUtils.tk_pk_asTitle(this.m_item.friendlyName)));
         }
         if(Boolean(m_element["imageBitmap_mc"]) && Boolean(this.m_item))
         {
            addWidget(new ObjectPreviewFrame(m_element.imageBitmap_mc,this.m_item));
         }
         if(m_element["vote_bt"])
         {
            addWidget(new FarmAnimatedButton(m_element.vote_bt,this.voteButtonClicked));
         }
         if(m_element["face_0_mc"])
         {
            addWidget(new FarmIcon(m_element.face_0_mc));
         }
         if(m_element["face_1_mc"])
         {
            addWidget(new FarmIcon(m_element.face_1_mc));
         }
         if(m_element["face_2_mc"])
         {
            addWidget(new FarmIcon(m_element.face_2_mc));
         }
      }
      
      public function updateItem(item:String) : void
      {
         var i:int = 0;
         var profilePic:FarmIcon = null;
         var newItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(item);
         if(Boolean(m_element) && Boolean(m_element.image_mc) && Boolean(getWidget(m_element.image_mc)))
         {
            removeWidget(m_element.image_mc);
            addWidget(new ObjectPreviewFrame(m_element.image_mc,newItem));
            this.m_item = newItem;
         }
         if(Boolean(m_element) && Boolean(m_element.imageBitmap_mc) && Boolean(getWidget(m_element.imageBitmap_mc)))
         {
            removeWidget(m_element.imageBitmap_mc);
            addWidget(new ObjectPreviewFrame(m_element.imageBitmap_mc,newItem));
            this.m_item = newItem;
         }
         if(this.m_item.type == "tree")
         {
            getWidget(m_element["imageBitmap_mc"]).visible = true;
            getWidget(m_element["image_mc"]).visible = false;
         }
         else
         {
            getWidget(m_element["imageBitmap_mc"]).visible = false;
            getWidget(m_element["image_mc"]).visible = true;
         }
         var textField:ZwTextField = getWidget(m_element.itemTitle_tf) as ZwTextField;
         if(textField)
         {
            textField.text = ZLocUtils.tk_pk_asTitle(this.m_item.friendlyName);
         }
         this.m_facePiles = Global.friendManager.getFriendObjects(FaceOffManager.getInstance().getFacePiles(this.m_item.name));
         if(this.m_facePiles)
         {
            i = 0;
            while(i < this.m_facePiles.length && Boolean(m_element["face_" + i.toString() + "_mc"]))
            {
               profilePic = getWidget(m_element["face_" + i.toString() + "_mc"]) as FarmIcon;
               if(Boolean(profilePic) && Boolean(this.m_facePiles[i]))
               {
                  (getWidget(profilePic) as FarmIcon).loadIcon(this.m_facePiles[i].picture);
               }
               i++;
            }
         }
         if(Boolean(m_element["face_0_mc"]) && Boolean(m_element["face_1_mc"]) && Boolean(m_element["face_2_mc"]))
         {
            if(this.m_facePileVariant == 2)
            {
               if(this.m_facePiles.length == 0)
               {
                  getWidget(m_element.face_0_mc).visible = false;
                  getWidget(m_element.face_1_mc).visible = false;
                  getWidget(m_element.face_2_mc).visible = false;
               }
               else if(this.m_facePiles.length == 1)
               {
                  getWidget(m_element.face_0_mc).visible = true;
                  getWidget(m_element.face_1_mc).visible = false;
                  getWidget(m_element.face_2_mc).visible = false;
               }
               else if(this.m_facePiles.length == 2)
               {
                  getWidget(m_element.face_0_mc).visible = true;
                  getWidget(m_element.face_1_mc).visible = false;
                  getWidget(m_element.face_2_mc).visible = true;
               }
               else if(this.m_facePiles.length == 3)
               {
                  getWidget(m_element.face_0_mc).visible = true;
                  getWidget(m_element.face_1_mc).visible = true;
                  getWidget(m_element.face_2_mc).visible = true;
               }
            }
            else if(m_element["face_0_mc"])
            {
               getWidget(m_element.face_0_mc).visible = false;
               getWidget(m_element.face_1_mc).visible = false;
               getWidget(m_element.face_2_mc).visible = false;
            }
         }
      }
      
      public function getItemName() : String
      {
         var result:String = "";
         if(this.m_item)
         {
            result = this.m_item.name;
         }
         return result;
      }
      
      public function voteButtonClicked(event:Event) : void
      {
         if(Boolean(this.m_item) && Boolean(this.m_window))
         {
            FaceOffManager.getInstance().vote(this.m_item.name);
            this.m_window.update();
         }
      }
   }
}

