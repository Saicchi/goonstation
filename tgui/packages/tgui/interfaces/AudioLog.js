/**
 * @file
 * @copyright 2022 Saicchi
 * @author Original Saicchi (https://github.com/Saicchi)
 * @license ISC
 */

import { useBackend } from '../backend';
import { Button, LabeledList, Section } from '../components';
import { Window } from '../layouts';

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
                    <LabeledList>
                        <LabeledList.Item label="Running">
                            <Button
                                content={isrunning ? "On" : "Off"}
                                color={isrunning ? "good" : "bad"}
                                onClick={() => { act("toggle_running") }} />
                        </LabeledList.Item>
                        <LabeledList.Item label="UseMode">
                            <Button
                                content={usemode ? "Playing" : "Recording"}
                                color={usemode ? "good" : "average"}
                                onClick={() => { act("toggle_mode") }} />
                        </LabeledList.Item>
                    </LabeledList>
                </Section>
            </Window.Content>
        </Window>
    );
}
