<?php

use Opencontent\Ocopendata\Forms\Connectors\OpendataConnector\ClassConnector;

class DimmiForumReplyClassConnector extends ClassConnector
{
	private $topic;

	private $topicConfig = array(
		'enable_attachments' => false,
		'enable_links' => false,
		'comment_and_vote' => false,
        'yes' => 'SI',
        'no' => 'NO',
	);

	public function __construct(eZContentClass $class, $helper)
	{
		parent::__construct($class, $helper);
		$topic = false;
		if ($this->getHelper()->hasParameter('parent')) {
			$topic = eZContentObjectTreeNode::fetch($this->getHelper()->getParameter('parent'));
		}elseif ($this->getHelper()->hasParameter('object')) {
			$object = eZContentObject::fetch($this->getHelper()->getParameter('object'));
			if ($object instanceof eZContentObject){
				$topic = $object->mainNode()->fetchParent();
			}
		}
		if ($topic instanceof eZContentObjectTreeNode && $topic->attribute('class_identifier') == 'dimmi_forum_topic'){			
			$this->topic = $topic;
			$dataMap = $this->topic->dataMap();
			$this->topicConfig['enable_attachments'] = $dataMap['enable_attachments']->attribute('data_int') == 1;
			$this->topicConfig['enable_links'] = $dataMap['enable_links']->attribute('data_int') == 1;
			$this->topicConfig['comment_and_vote'] = $dataMap['comment_and_vote']->attribute('data_int') == 1;
            $this->topicConfig['yes'] = $dataMap['yes_label']->toString();
            $this->topicConfig['no'] = $dataMap['no_label']->toString();
		}
	}

	public function getSchema()
    {
        $data = parent::getSchema();
        $data['title'] = '';
        if (!$this->topicConfig['enable_attachments']){
        	unset($data['properties']['attachments']);
        }
        if (!$this->topicConfig['enable_links']){
        	unset($data['properties']['links']);
        }
        if (!$this->topicConfig['comment_and_vote'] || !$this->topic){
        	unset($data['properties']['vote']);
        	$data['properties']['message']['required'] = true;
        }else{
        	$data['properties']['vote']['required'] = true;
        }
        return $data;
    }
    
    public function getOptions()
    {
    	$options = parent::getOptions();
		if ($this->topicConfig['comment_and_vote']){
        	$options['fields']['vote']['hideNone'] = true;
        	$options['fields']['vote']['type'] = 'radio';
        	$options['fields']['vote']['optionLabels'] = array($this->topicConfig['yes'], $this->topicConfig['no']);
        }
    	return $options;
    }

	public function submit()
    {       
        if ($this->topicConfig['comment_and_vote']) {
	        $remoteId = 'vote_' . $this->getHelper()->getParameter('parent') . '_' . eZUser::currentUserID();	        
	        if (!$this->isUpdate() && eZContentObject::fetchByRemoteID($remoteId)){
		    	throw new Exception(ezpI18n::tr( 'dimmi/forum', 'Hai già votato a questo sondaggio'), 1);
		    }
	    }

        $db = eZDB::instance();
        $db->begin();

        $payload = $this->getPayloadFromPostData();

		if(!$this->topic){
        	$message = trim($payload->getData('message', eZLocale::currentLocaleCode()));
        	if (empty($message)){        		
                throw new Exception(ezpI18n::tr( 'dimmi/forum', 'Insersci un testo'), 1);
        	}
        }

        $result = $this->doSubmit($payload);
        if ($this->topicConfig['comment_and_vote'] && !$this->isUpdate()) {
        	$object = eZContentObject::fetch((int)$result['content']['metadata']['id']);
	        if ($object instanceof eZContentObject){
	            $object->setAttribute('remote_id', $remoteId);
	            $object->store();
	        }
        }
		
		$db->commit();

        return $result;
    }

}