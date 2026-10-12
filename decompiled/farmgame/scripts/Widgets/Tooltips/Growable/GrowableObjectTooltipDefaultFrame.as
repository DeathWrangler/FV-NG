package Widgets.Tooltips.Growable
{
   import Classes.Friend;
   import Classes.Growable.GrowableConstants;
   import Classes.Growable.GrowableContest;
   import Classes.Growable.GrowableInstanceDataProxy;
   import Classes.Growable.IGrowableResource;
   import Classes.util.ObjectUtil;
   import Managers.GrowableContestManager;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class GrowableObjectTooltipDefaultFrame extends ZwFrame
   {
      
      private const FEATURE_DIALOG_PREFIX:String = "Window_";
      
      private var m_growableResource:IGrowableResource = null;
      
      private var m_contest:GrowableContest;
      
      private var m_friendIcon:FarmIcon;
      
      private var m_partnerId:String = String(NaN);
      
      private var m_background:ZwWidget;
      
      private var m_noFriendIcon:ZwWidget;
      
      private var m_statusTextField:ZwTextField;
      
      public function GrowableObjectTooltipDefaultFrame(element:DisplayObject, resource:IGrowableResource)
      {
         super(element);
         this.m_growableResource = resource;
         this.m_contest = GrowableContestManager.instance.getContestForInstance(resource);
         if(this.m_contest)
         {
            GrowableInstanceDataProxy.getInstanceForResource(resource).addEventListener(GrowableConstants.EVENT_DATA_CHANGED,this.handleInstanceDataChanged);
            if(ObjectUtil.pathExists(m_element,"noFriend_mc"))
            {
               this.m_noFriendIcon = addWidget(new ZwWidget(m_element["noFriend_mc"])) as ZwWidget;
            }
            if(ObjectUtil.pathExists(m_element,"back_mc"))
            {
               this.m_background = addWidget(new ZwWidget(m_element["back_mc"])) as ZwWidget;
            }
            if(ObjectUtil.pathExists(m_element,"timeLeft_tf"))
            {
               this.m_statusTextField = addWidget(new ZwTextField(m_element.timeLeft_tf)) as ZwTextField;
            }
         }
         this.refreshUI();
      }
      
      private function handleInstanceDataChanged(e:Event) : void
      {
         this.refreshUI();
      }
      
      public function refreshUI() : void
      {
         var tmpContestEntry:Object = this.contestEntry;
         if(tmpContestEntry != null)
         {
            this.setPartnerId(tmpContestEntry.partner);
            this.m_statusTextField.text = this.m_growableResource.getTimeTilExpire(false,true);
         }
      }
      
      private function setPartnerId(partnerId:String) : void
      {
         var friend:Friend = null;
         if(partnerId != this.m_partnerId)
         {
            this.m_partnerId = partnerId;
            if(this.m_friendIcon)
            {
               removeWidget(this.m_friendIcon);
            }
            if(partnerId != "0")
            {
               friend = Global.friendManager.getFriendData(partnerId);
               if(friend != null)
               {
                  if(ObjectUtil.pathExists(m_element,"icon_mc"))
                  {
                     this.m_friendIcon = new FarmIcon(m_element.icon_mc,friend.picture);
                     addWidget(this.m_friendIcon);
                  }
               }
            }
         }
      }
      
      private function get contestEntry() : Object
      {
         return this.m_contest ? this.m_contest.getContestEntryForKey(this.m_growableResource.persistentDataKey) : null;
      }
      
      private function get instanceData() : Object
      {
         return this.m_growableResource.getGrowableInstanceData();
      }
      
      override public function release() : void
      {
         GrowableInstanceDataProxy.getInstanceForResource(this.m_growableResource).removeEventListener(GrowableConstants.EVENT_DATA_CHANGED,this.handleInstanceDataChanged);
         this.m_background = null;
         this.m_noFriendIcon = null;
         this.m_growableResource = null;
         this.m_contest = null;
         super.release();
      }
      
      public function show() : void
      {
         visible = true;
      }
      
      public function hide() : void
      {
         visible = false;
      }
      
      public function statCount(phylum:String = "", zclass:String = "", family:String = "", genus:String = "", value:int = 1) : void
      {
         if(this.m_contest)
         {
            this.m_contest.statCount("contest_menu",phylum,zclass,family,genus,value);
         }
      }
   }
}

