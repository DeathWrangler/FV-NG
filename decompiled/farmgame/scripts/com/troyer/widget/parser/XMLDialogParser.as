package com.troyer.widget.parser
{
   import com.troyer.widget.Constants;
   import com.troyer.widget.MT4DManager;
   import com.troyer.widget.style.BaseStyle;
   import com.troyer.widget.view.BaseWidgetView;
   import flash.filters.BitmapFilter;
   import flash.utils.Dictionary;
   import flash.utils.getDefinitionByName;
   import flash.utils.getQualifiedClassName;
   
   public class XMLDialogParser extends DialogParser
   {
      
      private static var m_instance:XMLDialogParser;
      
      private var m_xml:XML;
      
      public function XMLDialogParser()
      {
         super(this);
         if(m_instance)
         {
            throw new Error("XMLDialogParser singleton has already been created.");
         }
         m_instance = this;
      }
      
      public static function getInstance() : XMLDialogParser
      {
         if(!m_instance)
         {
            new XMLDialogParser();
         }
         return m_instance;
      }
      
      override protected function doParse(param1:*) : void
      {
         this.m_xml = new XML(param1);
         if(this.m_xml)
         {
            if(this.m_xml.styles.length() > 0)
            {
               this.parseStyles();
            }
            if(this.m_xml.dialogLooks.length() > 0)
            {
               this.parseLooks();
            }
            if(this.m_xml.views.length() > 0)
            {
               this.parseViews();
            }
            if(this.m_xml.dialogs.length() > 0)
            {
               this.parseDialogs();
            }
            if(this.m_xml.sampletext.length() > 0)
            {
               this.parseSampleText();
            }
         }
         else
         {
            addError("Bad XML Data passed to parser");
         }
         this.m_xml = null;
      }
      
      private function parseStyles() : void
      {
         var _loc1_:XML = null;
         var _loc2_:String = null;
         var _loc3_:Dictionary = null;
         var _loc4_:String = null;
         var _loc5_:BaseStyle = null;
         var _loc6_:XML = null;
         var _loc7_:XML = null;
         var _loc8_:Dictionary = null;
         var _loc9_:Array = null;
         var _loc10_:XML = null;
         var _loc11_:Array = null;
         var _loc12_:XML = null;
         var _loc13_:Class = null;
         var _loc14_:BitmapFilter = null;
         var _loc15_:Dictionary = null;
         var _loc16_:String = null;
         var _loc17_:Array = null;
         var _loc18_:XML = null;
         var _loc19_:Dictionary = null;
         var _loc20_:Dictionary = null;
         var _loc21_:XMLList = null;
         var _loc22_:XML = null;
         for each(_loc1_ in this.m_xml.styles.style)
         {
            _loc2_ = _loc1_.@name;
            _loc3_ = new Dictionary();
            if("@extends" in _loc1_)
            {
               _loc4_ = _loc1_.attribute("extends");
               if(m_styles[_loc4_])
               {
                  _loc3_ = Utility.cloneDictionary(m_styles[_loc4_]);
               }
               else
               {
                  _loc5_ = MT4DManager.getInstance().getStyle(_loc4_);
                  if(_loc5_)
                  {
                     _loc3_ = _loc5_.serialize();
                  }
                  else
                  {
                     addError("Style \'" + _loc2_ + "\' extends " + _loc4_ + " that doesn\'t exist.");
                  }
               }
            }
            if(_loc1_.hasOwnProperty(Constants.STYLE_TAG_SKIN))
            {
               _loc3_[Constants.STYLE_TAG_SKIN] = new Dictionary();
               _loc6_ = _loc1_.skin[0];
               if(!_loc6_.hasOwnProperty("view"))
               {
                  addError("Style \'" + _loc2_ + "\' <skin> section must have a <view> tag.");
               }
               else
               {
                  _loc7_ = _loc6_.view.children()[0];
                  _loc8_ = this.recurseViewXML(_loc7_);
                  _loc3_[Constants.STYLE_TAG_SKIN].view = _loc8_;
                  m_views[BaseWidgetView.SKIN_VIEW_PREFIX + _loc2_ + BaseWidgetView.SKIN_VIEW_SUFFIX] = _loc8_;
               }
               if(!_loc6_.hasOwnProperty("target"))
               {
                  addError("Style \'" + _loc2_ + "\' <skin> section must have a <target> tag.");
               }
               else
               {
                  _loc3_[Constants.STYLE_TAG_SKIN].target = _loc6_.target.toString();
               }
               if(_loc6_.hasOwnProperty("injectTarget"))
               {
                  _loc3_[Constants.STYLE_TAG_SKIN].injectTarget = _loc6_.injectTarget.toString();
               }
            }
            if(_loc1_.hasOwnProperty(Constants.STYLE_TAG_COLORS))
            {
               _loc9_ = new Array();
               for each(_loc10_ in _loc1_.colors.color)
               {
                  _loc9_.push(uint(_loc10_));
               }
               _loc3_[Constants.STYLE_TAG_COLORS] = _loc9_;
            }
            if(_loc1_.hasOwnProperty(Constants.STYLE_TAG_FILTERS))
            {
               _loc11_ = new Array();
               for each(_loc12_ in _loc1_.filters.filter)
               {
                  if(_loc12_.@className)
                  {
                     _loc13_ = getDefinitionByName("flash.filters::" + _loc12_.@className) as Class;
                     if(_loc13_)
                     {
                        _loc14_ = new _loc13_();
                        _loc15_ = this.xmlChildrenToDictionary(_loc12_);
                        for(_loc16_ in _loc15_)
                        {
                           if(_loc14_.hasOwnProperty(_loc16_))
                           {
                              _loc14_[_loc16_] = _loc15_[_loc16_];
                           }
                           else
                           {
                              addError("Unknown parameter: " + _loc16_ + " in filter: " + _loc12_.@className);
                           }
                        }
                        _loc11_.push(_loc14_);
                     }
                  }
               }
               _loc3_[Constants.STYLE_TAG_FILTERS] = _loc11_;
            }
            if(_loc1_.hasOwnProperty(Constants.STYLE_TAG_FONTS))
            {
               _loc17_ = new Array();
               for each(_loc18_ in _loc1_.fonts.font)
               {
                  _loc19_ = this.xmlAttributesToDictionary(_loc18_);
                  _loc19_[BaseStyle.FONT_FORMATTING] = this.xmlChildrenToDictionary(_loc18_);
                  _loc17_.push(_loc19_);
               }
               _loc3_[Constants.STYLE_TAG_FONTS] = _loc17_;
            }
            if(_loc1_.hasOwnProperty(Constants.STYLE_TAG_DATA))
            {
               if(_loc3_.hasOwnProperty(Constants.STYLE_TAG_DATA))
               {
                  _loc20_ = _loc3_[Constants.STYLE_TAG_DATA];
               }
               else
               {
                  _loc20_ = new Dictionary();
               }
               _loc21_ = _loc1_.data.children();
               for each(_loc22_ in _loc21_)
               {
                  _loc20_[_loc22_.name()] = _loc22_.toString();
               }
               _loc3_[Constants.STYLE_TAG_DATA] = _loc20_;
            }
            _loc3_.name = _loc2_;
            m_styles[_loc2_] = _loc3_;
         }
      }
      
      private function parseLooks() : void
      {
         var _loc1_:XML = null;
         var _loc2_:String = null;
         var _loc3_:Dictionary = null;
         var _loc4_:Dictionary = null;
         var _loc5_:XML = null;
         var _loc6_:String = null;
         var _loc7_:String = null;
         for each(_loc1_ in this.m_xml.dialogLooks.dialogLook)
         {
            _loc2_ = _loc1_.@name;
            _loc3_ = new Dictionary();
            _loc3_.name = _loc2_;
            _loc4_ = new Dictionary();
            for each(_loc5_ in _loc1_.mapStyle)
            {
               _loc6_ = _loc5_.@name;
               _loc7_ = _loc5_.@toStyle;
               _loc4_[_loc6_] = _loc7_;
            }
            _loc3_[Constants.TAG_DIALOG_LOOK] = _loc4_;
            m_looks[_loc2_] = _loc3_;
         }
      }
      
      private function parseViews() : void
      {
         var _loc1_:XML = null;
         var _loc2_:Dictionary = null;
         var _loc3_:String = null;
         for each(_loc1_ in this.m_xml.views.children())
         {
            _loc2_ = this.recurseViewXML(_loc1_);
            if(Boolean(_loc2_) && Boolean(_loc2_.hasOwnProperty(Constants.ATTRIBUTES)) && Boolean(_loc2_[Constants.ATTRIBUTES].hasOwnProperty(Constants.ATTRIBUTE_NAME)))
            {
               _loc3_ = _loc2_[Constants.ATTRIBUTES][Constants.ATTRIBUTE_NAME];
               if(m_views.hasOwnProperty(_loc3_))
               {
                  addError("view \'" + _loc3_ + "\' already exists in xml.");
                  return;
               }
               m_views[_loc3_] = _loc2_;
            }
            else
            {
               addError("view contains no name in: " + _loc1_.toString());
            }
         }
      }
      
      private function recurseViewXML(param1:XML) : Dictionary
      {
         var _loc3_:String = null;
         var _loc4_:Dictionary = null;
         var _loc5_:Dictionary = null;
         var _loc6_:Dictionary = null;
         var _loc7_:String = null;
         var _loc8_:Array = null;
         var _loc9_:XML = null;
         var _loc10_:Dictionary = null;
         var _loc11_:String = null;
         var _loc12_:Array = null;
         var _loc13_:String = null;
         var _loc14_:Class = null;
         var _loc15_:String = null;
         var _loc16_:int = 0;
         var _loc17_:Array = null;
         var _loc18_:XML = null;
         var _loc19_:Dictionary = null;
         var _loc2_:Dictionary = null;
         if(param1.nodeKind() != "element")
         {
            addError("Only view element tags expected in views.  Found: " + param1.nodeKind() + ".");
            return null;
         }
         if(param1.name() == Constants.VIEW_IMPORT_TAG)
         {
            if(param1.@view)
            {
               _loc3_ = param1.@view;
               _loc4_ = findViewDefinition(_loc3_);
               if(_loc4_)
               {
                  _loc5_ = Utility.cloneDictionary(_loc4_);
                  _loc6_ = this.xmlAttributesToDictionary(param1);
                  if(param1.*.length() > 0)
                  {
                     _loc8_ = new Array();
                     for each(_loc9_ in param1.children())
                     {
                        _loc8_.push(this.recurseViewXML(_loc9_));
                     }
                     _loc10_ = _loc5_;
                     if(_loc6_.hasOwnProperty(Constants.VIEW_IMPORT_INJECTION))
                     {
                        _loc11_ = _loc6_[Constants.VIEW_IMPORT_INJECTION];
                        _loc10_ = Utility.findViewInDictionary(_loc11_,_loc5_);
                     }
                     if(_loc10_)
                     {
                        if(_loc10_.hasOwnProperty(Constants.CHILDREN))
                        {
                           _loc12_ = _loc10_[Constants.CHILDREN] as Array;
                           _loc10_[Constants.CHILDREN] = _loc12_.concat(_loc8_);
                        }
                        else
                        {
                           _loc10_[Constants.CHILDREN] = _loc8_;
                        }
                     }
                     else
                     {
                        addError("Unable to find a view named \'" + _loc11_ + "\' for import injection in view \'" + _loc3_ + "\'.");
                     }
                     delete _loc6_[Constants.VIEW_IMPORT_INJECTION];
                  }
                  for(_loc7_ in _loc6_)
                  {
                     _loc5_[Constants.ATTRIBUTES][_loc7_] = _loc6_[_loc7_];
                  }
                  _loc2_ = _loc5_;
               }
               else
               {
                  addError("import name \'" + _loc3_ + "\' not found in xml.");
               }
            }
            else
            {
               addError("import tag without a view attribute: " + param1.toString());
            }
         }
         else
         {
            _loc2_ = new Dictionary();
            _loc2_[Constants.ATTRIBUTES] = this.xmlAttributesToDictionary(param1);
            if(param1.name() != Constants.VIEW_TAG)
            {
               _loc13_ = param1.name();
               _loc14_ = findViewOrControllerClass(_loc13_);
               if(_loc14_ != null)
               {
                  _loc15_ = getQualifiedClassName(_loc14_);
                  _loc16_ = _loc15_.charCodeAt(_loc15_.length - 1);
                  if(_loc16_ == 114)
                  {
                     _loc2_[Constants.ATTRIBUTES]["controller"] = _loc13_;
                  }
                  else if(_loc16_ == 119)
                  {
                     _loc2_[Constants.ATTRIBUTES]["className"] = _loc13_;
                  }
                  _loc2_[Constants.TAG_NAME] = _loc13_;
               }
               else
               {
                  addError("Unknown view or controller \'" + _loc13_ + "\'.");
               }
            }
            if(param1.*.length() > 0)
            {
               _loc17_ = new Array();
               for each(_loc18_ in param1.children())
               {
                  _loc19_ = this.recurseViewXML(_loc18_);
                  _loc17_.push(_loc19_);
               }
               _loc2_[Constants.CHILDREN] = _loc17_;
            }
         }
         return _loc2_;
      }
      
      private function parseDialogs() : void
      {
         var _loc1_:XML = null;
         var _loc2_:Dictionary = null;
         var _loc3_:String = null;
         for each(_loc1_ in this.m_xml.dialogs.dialog)
         {
            _loc2_ = new Dictionary();
            _loc2_[Constants.ATTRIBUTES] = this.xmlAttributesToDictionary(_loc1_);
            _loc2_[Constants.CHILDREN] = this.xmlChildrenToArray(_loc1_);
            if(_loc2_[Constants.ATTRIBUTES].hasOwnProperty(Constants.ATTRIBUTE_NAME))
            {
               _loc3_ = _loc2_[Constants.ATTRIBUTES][Constants.ATTRIBUTE_NAME];
               m_dialogs[_loc3_] = _loc2_;
            }
            else
            {
               addError("Dialog does not contain name attribute: " + _loc1_.toString());
            }
         }
      }
      
      private function parseSampleText() : void
      {
         var _loc1_:XML = null;
         var _loc2_:String = null;
         for each(_loc1_ in this.m_xml.sampletext.text)
         {
            if(_loc1_.attributes().length() == 1 && "@key" in _loc1_)
            {
               _loc2_ = _loc1_.text()[0].toString();
               _loc2_ = _loc2_.replace("\n","");
               _loc2_ = _loc2_.replace("\r","");
               m_sampleText[_loc1_.@key[0].toString()] = _loc2_;
            }
            else
            {
               addError("Expecting a single \'key\' attribute in <text> tag.");
            }
         }
      }
      
      private function xmlAttributesToDictionary(param1:XML) : Dictionary
      {
         var _loc4_:XML = null;
         var _loc2_:XMLList = param1.attributes();
         var _loc3_:Dictionary = new Dictionary();
         _loc3_[Constants.TAG_NAME] = param1.name();
         for each(_loc4_ in _loc2_)
         {
            _loc3_[_loc4_.name().toString()] = _loc4_.toString();
         }
         return _loc3_;
      }
      
      private function xmlChildrenToArray(param1:XML) : Array
      {
         var _loc4_:XML = null;
         var _loc2_:Array = new Array();
         var _loc3_:XMLList = param1.children();
         for each(_loc4_ in _loc3_)
         {
            if(_loc4_.attributes().length() > 0)
            {
               _loc2_.push(this.xmlAttributesToDictionary(_loc4_));
            }
            else if(_loc4_.*.length() > 1)
            {
               _loc2_.push(this.xmlChildrenToDictionary(_loc4_));
            }
            else
            {
               _loc2_.push(_loc4_.toString());
            }
         }
         return _loc2_;
      }
      
      private function xmlChildrenToDictionary(param1:XML) : Dictionary
      {
         var _loc4_:XML = null;
         var _loc2_:Dictionary = new Dictionary();
         var _loc3_:XMLList = param1.children();
         for each(_loc4_ in _loc3_)
         {
            if(_loc4_.attributes().length() > 0)
            {
               _loc2_[_loc4_.name().toString()] = this.xmlAttributesToDictionary(_loc4_);
            }
            else if(_loc4_.*.length() > 1)
            {
               _loc2_[_loc4_.name().toString()] = this.xmlChildrenToDictionary(_loc4_);
            }
            else
            {
               _loc2_[_loc4_.name().toString()] = _loc4_.toString();
            }
         }
         return _loc2_;
      }
   }
}

