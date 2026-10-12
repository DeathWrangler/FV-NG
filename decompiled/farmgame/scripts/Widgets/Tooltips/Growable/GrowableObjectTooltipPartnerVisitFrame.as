package Widgets.Tooltips.Growable
{
   import Classes.Friend;
   import Classes.Growable.GrowableConstants;
   import Classes.Growable.GrowableContest;
   import Classes.Growable.GrowableInstanceDataProxy;
   import Classes.Growable.IGrowableResource;
   import Classes.util.ObjectUtil;
   import Classes.util.ZLocUtils;
   import Managers.GrowableContestManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class GrowableObjectTooltipPartnerVisitFrame extends ZwFrame
   {
      
      private const FEATURE_DIALOG_PREFIX:String = "Window_";
      
      private var m_growableResource:IGrowableResource = null;
      
      private var m_contest:GrowableContest;
      
      private var m_partnerId:String = String(NaN);
      
      private var m_friendIcon:FarmIcon;
      
      private var m_background:ZwWidget;
      
      private var m_acceptButton:FarmAnimatedTextButton;
      
      private var m_actionText:ZwTextField;
      
      private var m_partnerNameText:ZwTextField;
      
      public function GrowableObjectTooltipPartnerVisitFrame(element:DisplayObject, resource:IGrowableResource)
      {
         super(element);
         this.m_growableResource = resource;
         this.m_contest = GrowableContestManager.instance.getContestForInstance(resource);
         if(this.m_contest)
         {
            GrowableInstanceDataProxy.getInstanceForResource(resource).addEventListener(GrowableConstants.EVENT_DATA_CHANGED,this.handleInstanceDataChanged);
            if(ObjectUtil.pathExists(m_element,"back_mc"))
            {
               this.m_background = addWidget(new ZwWidget(m_element["back_mc"])) as ZwWidget;
            }
            if(ObjectUtil.pathExists(m_element,"partners_tf"))
            {
               this.m_partnerNameText = new ZwTextField(m_element.partners_tf,ZLocUtils.tk_pk_asTitle(this.m_growableResource.growableMapResource.getItemFriendlyName()));
               addWidget(this.m_partnerNameText);
            }
            if(ObjectUtil.pathExists(m_element,"timeLeft_tf"))
            {
               this.m_actionText = addWidget(new ZwTextField(m_element.timeLeft_tf,this.m_contest.getZLocString("Dialogs",this.FEATURE_DIALOG_PREFIX + "PartnerActionText"))) as ZwTextField;
            }
            if(ObjectUtil.pathExists(m_element,"feed_bt"))
            {
               this.m_acceptButton = addWidget(new FarmAnimatedTextButton(m_element["feed_bt"],this.m_contest.getZLocString("Dialogs",this.FEATURE_DIALOG_PREFIX + "AcceptPartner"),this.handlePartnerAcceptButtonClicked)) as FarmAnimatedTextButton;
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
            this.m_partnerNameText.visible = false;
            if(partnerId != "0")
            {
               friend = Global.friendManager.getFriendData(partnerId);
               if(friend != null)
               {
                  this.m_partnerNameText.text = friend.name;
                  if(ObjectUtil.pathExists(m_element,"icon_mc"))
                  {
                     this.m_friendIcon = new FarmIcon(m_element.icon_mc,friend.picture);
                     addWidget(this.m_friendIcon);
                  }
                  this.m_partnerNameText.visible = true;
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
      
      private function handlePartnerAcceptButtonClicked(e:MouseEvent) : void
      {
         if(this.m_contest)
         {
            this.m_contest.acceptHelp(this.m_growableResource,this.handlePartnerAcceptButtonCallback);
            parent.hideAllFrames();
            this.statCount("okay");
         }
      }
      
      private function handlePartnerAcceptButtonCallback(data:Object) : void
      {
         this.m_growableResource.refreshVisibleToActual(data.stage);
         this.m_growableResource.growableMapResource.reloadImage();
      }
      
      override public function release() : void
      {
         GrowableInstanceDataProxy.getInstanceForResource(this.m_growableResource).removeEventListener(GrowableConstants.EVENT_DATA_CHANGED,this.handleInstanceDataChanged);
         this.m_friendIcon = null;
         this.m_background = null;
         this.m_acceptButton = null;
         this.m_actionText = null;
         this.m_partnerNameText = null;
         this.m_contest = null;
         super.release();
      }
      
      public function show() : void
      {
         if(!visible)
         {
            this.statCount("impressions");
            visible = true;
         }
      }
      
      public function hide() : void
      {
         visible = false;
      }
      
      public function statCount(phylum:String = "", zclass:String = "", family:String = "", genus:String = "", value:int = 1) : void
      {
         if(this.m_contest)
         {
            this.m_contest.statCount("partner_fed_tooltip",phylum,zclass,family,genus,value);
         }
      }
   }
}

