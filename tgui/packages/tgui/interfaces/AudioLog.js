/**
 * @file
 * @copyright 2022 Saicchi
 * @author Original Saicchi (https://github.com/Saicchi)
 * @license ISC
 */

import { useBackend } from '../backend';
import { classes } from 'common/react';
import { Button, Box, Flex, Section } from '../components';
import { Window } from '../layouts';

export const PlayButton = (props) => {
    const {
        act,
        isrunning
    } = props;

    return (
        <Flex
            direction="column" align="center" backgroundColor="blue">
            <Box as="span" class="AudioLog__MainToggle">Test</Box>
            <Button
                content={isrunning ? "On" : "Off"}
                color={isrunning ? "good" : "bad"}w
                onClick={() => { act("toggle_running") }} />
        </Flex>
    )
};

export const RecordButton = (props) => {
    const {
        act,
        usemode
    } = props;

    return (
        <Button
            content={usemode ? "Playing" : "Recording"}
            color={usemode ? "good" : "average"}
            onClick={() => { act("toggle_mode") }} />
    )
};


export const AudioLog = (props, context) => {
    const { act, data } = useBackend(context);
    // Extract `health` and `color` variables from the `data` object.
    const {
        isrunning,
        usemode
    } = data;

    return (
        <Window>
            <Window.Content>
                <Section title="Stats">
                    <PlayButton act={act} isrunning={isrunning} />
                    <RecordButton act={act} usemode={usemode} />
                </Section>
            </Window.Content>
        </Window>
    );
}
